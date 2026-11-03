/*
 * Золотой 3D-объект первого экрана страницы услуги — WebGL, three.js r158 (металл и «студия» — как у икосаэдра
 * SEO-блока и спирали section 6). Два вида (значение data-rd-knot):
 *   ""        — узел-трилистник (Landing и др.; описание ниже);
 *   "pyramid" — четырёхгранная пирамида со скруглёнными рёбрами (страница копирайтинга): сумма Минковского
 *               пирамиды и шарика — каждая точка густой сферы уходит в опорную вершину пирамиды по своей нормали,
 *               грани плоские, рёбра — цилиндры, вершины — шаровые «шапочки»; на скруглённом ребре — блик, как в макете.
 *               Вращается вокруг вертикальной оси пирамиды.
 * Форма — трилистник: трубка TUBE вдоль кривой u ∈ [0, 4π): r = 1 + A·cos(1.5u), точка (r·cos u, r·sin u, H·sin(1.5u)).
 * Поза и форма подобраны по силуэту картинки макета (knot.webp, 600×600; tools/knot_fit.py) и сверены рендером:
 * поворот ROT (ось·угол), масштаб SCALE (доля стороны блока на единицу кривой), сдвиг CENTER.
 * Узел вращается вокруг своей оси симметрии (z кривой) — силуэт всё время похож на макет.
 *
 * Разметка: .rd-hero__glob[data-rd-knot] > picture > img.rd-hero__blob (svc-hero.tpl).
 * Канвас .rd-hero__canvas вставляется в .rd-hero__glob; после первого кадра на нём .is-webgl (картинка гаснет).
 * Без WebGL / при reduced motion остаётся картинка (rd-wow.js через 3 с ставит .is-fallback).
 *
 * Движение: медленное вращение вокруг оси узла; при первом появлении — раскрутка; прокрутка подкручивает;
 * курсор рядом — наклон к нему и быстрее вращение; лёгкое покачивание.
 * Для проверки: document.querySelector('[data-rd-knot]').rdKnot (still = true — замереть в позе макета,
 * setShape({ tube }), setLight(LIGHT), pose()).
 */
import {
  Scene,
  PerspectiveCamera,
  WebGLRenderer,
  Group,
  Mesh,
  Curve,
  TubeGeometry,
  Vector3,
  Quaternion,
  MeshStandardMaterial,
  MeshBasicMaterial,
  BoxGeometry,
  PlaneGeometry,
  IcosahedronGeometry,
  Float32BufferAttribute,
  Color,
  BackSide,
  DoubleSide,
  PMREMGenerator,
  DirectionalLight,
  NoToneMapping,
} from 'three';

const CAMERA_Z = 3900; // далеко — почти без перспективы, как рендер в макете
const PAD = 1.25; // канвас больше блока: наклон и покачивание не обрезаются
const SCALE = 0.205; // доля стороны блока на единицу кривой (видимая ширина узла ≈ 75% блока, как у картинки)
const TUBE = 0.42; // толщина трубки (в единицах кривой) — как у рендера макета
const ROT = [-0.382,  0.382,  0.8521]; // поза: ось·угол — крен −20°, наклон оси узла 30°, поворот 70° (tools/knot_fit.py + сверка рендером)
const CENTER = [0.02, 0]; // сдвиг центра узла от центра блока (доли стороны; y — вверх)
const SPIN = 0.35; // рад/с — обычное вращение вокруг оси узла
const SHAPE = { tube: TUBE, a: 0.5, h: 0.5 }; // трубка и амплитуды кривой (A — по радиусу, H — по высоте)
const Z_AXIS = new Vector3(0, 0, 1); // ось симметрии трилистника в координатах геометрии
const Y_AXIS = new Vector3(0, 1, 0); // ось пирамиды

// пирамида: квадратное основание (вершины на осях x / z, половина диагонали — 1), высота H, скругление R;
// поза, масштаб и сдвиг — по картинке макета (pyramid.webp, 600×600)
// (tools/pyramid_fit.py: IoU силуэта с картинкой макета 0.956; скругление — на глаз, по ширине блика на ребре)
const PYRAMID = {
  h: 0.85,
  r: 0.07,
  scale: 0.425,
  rot: [0.3799, -0.0095, 0.0494], // наклон к зрителю ~22° и лёгкий крен; поворот вокруг оси — angle (в макете −0.27)
  angle: -0.27,
  center: [0.015, -0.03],
  spin: 0.3,
};

// «студия» пирамиды: в позе макета левая грань отражает тёплый свет слева сверху (золото), правая — тёмную
// коричневую стену справа (тёмная бронза), скруглённое переднее ребро — узкий яркий блик над зрителем
const LIGHT_PYRAMID = {
  room: '#1e1108',
  panels: [
    [9, 9, -7.3, 4.4, -3.1, 0.22, '#ffdca8'], // слева сверху (левая грань)
    [10, 10, 5.4, 5.7, 4.5, 0.5, '#5c3418'], // справа сверху спереди (правая грань) — тёмная бронза
    [5, 8, -3.2, 7.1, 4.3, 4.5, '#fffaf0'], // узкий блик — переднее ребро
    [14, 4, -1.5, 9.2, -1.0, 1.1, '#ffe8c0'], // сверху
    [24, 24, 0.9, -2, -9.4, 0.5, '#4a3020'], // стена сзади
    [12, 8, 0, -8, 2, 0.5, '#2a160a'], // внизу — тёмный
  ],
  dirs: [],
};

function roundedPyramid(h, r) {
  const core = [[1, 0, 0], [0, 0, 1], [-1, 0, 0], [0, 0, -1], [0, h, 0]].map(([x, y, z]) => new Vector3(x, y - h * 0.3, z));
  const g = new IcosahedronGeometry(1, 64);
  const pos = g.getAttribute('position');
  const normals = new Float32Array(pos.count * 3);
  const n = new Vector3();
  for (let i = 0; i < pos.count; i++) {
    n.fromBufferAttribute(pos, i).normalize();
    let best = core[0];
    let bestD = -Infinity;
    for (const v of core) {
      const d = v.dot(n);
      if (d > bestD + 1e-9) { bestD = d; best = v; }
    }
    pos.setXYZ(i, best.x + n.x * r, best.y + n.y * r, best.z + n.z * r);
    n.toArray(normals, i * 3);
  }
  g.setAttribute('normal', new Float32BufferAttribute(normals, 3));
  g.deleteAttribute('uv');
  return g;
}

class TrefoilCurve extends Curve {
  constructor(a, h) {
    super();
    this.a = a;
    this.h = h;
  }

  getPoint(t, target = new Vector3()) {
    const u = t * Math.PI * 4;
    const r = 1 + this.a * Math.cos(1.5 * u);
    return target.set(r * Math.cos(u), r * Math.sin(u), this.h * Math.sin(1.5 * u));
  }
}

// «студия», которую отражает металл (x — вправо, y — вверх, z — к зрителю): крем спереди и сверху слева,
// тёплая коричневая комната, оливково-тёмный низ — как у рендера макета
const LIGHT = {
  room: '#2e1c0a',
  panels: [
    // [ширина, высота, x, y, z, яркость, цвет]
    [9, 9, -2.2, 1.6, 8.6, 1.9, '#ffeec8'], // спереди слева
    [12, 5, -1.5, 8.6, 1.6, 1.7, '#fff2d2'], // сверху
    [24, 24, 0.9, 0, -9.4, 0.9, '#5a4a3a'], // стена сзади
    [8, 10, 7.8, -0.5, 3.2, 0.7, '#7a5a3a'], // справа (слабый заполняющий)
    [10, 8, -4.8, -7.2, 1.5, 0.8, '#3a2a0c'], // внизу слева — тёмная олива
    [5, 3, -3.4, 4.8, 6.6, 2.4, '#fff4d8'], // узкий блик
  ],
  dirs: [],
};

const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
const damp = (k, dt) => 1 - Math.pow(k, dt);

class GoldKnot {
  constructor(box) {
    this.box = box;
    this.visible = true;
    this.last = performance.now();
    this.angle = 0;
    this.boost = 0;
    this.scrollV = 0;
    this.near = 0;
    this.nearTarget = 0;
    this.tilt = { x: 0, y: 0 };
    this.tiltTarget = { x: 0, y: 0 };
    this.lastScroll = window.scrollY;
    this.shown = false;
    this.still = false;
    this.kind = box.getAttribute('data-rd-knot') === 'pyramid' ? 'pyramid' : 'knot';
    this.axis = this.kind === 'pyramid' ? Y_AXIS : Z_AXIS;
    this.spin = this.kind === 'pyramid' ? PYRAMID.spin : SPIN;
    box.rdKnot = this;

    this.scene = new Scene();
    this.camera = new PerspectiveCamera(10, 1, 1, CAMERA_Z * 2);
    this.camera.position.set(0, 0, CAMERA_Z);

    this.renderer = new WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'low-power' });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    this.renderer.toneMapping = NoToneMapping;

    this.material = this.kind === 'pyramid'
      ? new MeshStandardMaterial({ color: '#eed29c', metalness: 1, roughness: 0.24, envMapIntensity: 1.6, emissive: '#1a0e05' })
      : new MeshStandardMaterial({
        color: '#ece2c4', // бледное золото: блики кремовые, как в макете
        metalness: 1,
        roughness: 0.2,
        envMapIntensity: 1.85,
        emissive: '#2a1e0e',
      });
    this.lights = [];
    this.setLight(this.kind === 'pyramid' ? LIGHT_PYRAMID : LIGHT);
    if (this.kind === 'pyramid') this.angle = PYRAMID.angle;

    const rot = this.kind === 'pyramid' ? PYRAMID.rot : ROT;
    this.base = new Quaternion().setFromAxisAngle(new Vector3(...rot).normalize(), Math.hypot(...rot));
    this.spinQ = new Quaternion();
    this.mesh = new Mesh(undefined, this.material);
    this.scaleK = this.kind === 'pyramid' ? PYRAMID.scale : SCALE;
    this.center = this.kind === 'pyramid' ? PYRAMID.center : CENTER;
    this.setShape({});
    this.tiltGroup = new Group();
    this.tiltGroup.add(this.mesh);
    this.root = new Group();
    this.root.add(this.tiltGroup);
    this.scene.add(this.root);

    this.canvas = this.renderer.domElement;
    this.canvas.className = 'rd-hero__canvas';
    this.canvas.setAttribute('aria-hidden', 'true');
    box.appendChild(this.canvas);

    this.resize();
    this.bind();
    this.loop = this.loop.bind(this);
    requestAnimationFrame(this.loop);
  }

  setLight(light) {
    this.light = light;
    const env = new Scene();
    env.add(new Mesh(new BoxGeometry(40, 40, 40), new MeshBasicMaterial({ color: light.room, side: BackSide })));
    light.panels.forEach(([w, h, x, y, z, k, c]) => {
      const m = new Mesh(new PlaneGeometry(w, h), new MeshBasicMaterial({ color: new Color(c).multiplyScalar(k), side: DoubleSide }));
      m.position.set(x, y, z);
      m.lookAt(0, 0, 0);
      env.add(m);
    });
    const pmrem = new PMREMGenerator(this.renderer);
    if (this.scene.environment) this.scene.environment.dispose();
    this.scene.environment = pmrem.fromScene(env, 0.02).texture;
    pmrem.dispose();
    env.traverse((o) => {
      if (o.isMesh) {
        o.geometry.dispose();
        o.material.dispose();
      }
    });
    this.lights.forEach((l) => this.scene.remove(l));
    this.lights = light.dirs.map(([x, y, z, k, c]) => {
      const l = new DirectionalLight(c, k);
      l.position.set(x, y, z);
      this.scene.add(l);
      return l;
    });
  }

  // tube — толщина трубки, a / h — амплитуды кривой; mirror — зеркальный узел (перекрёстки наоборот)
  // пирамида: h — высота, r — скругление рёбер
  setShape(shape) {
    if (this.mesh.geometry) this.mesh.geometry.dispose();
    if (this.kind === 'pyramid') {
      this.shape = Object.assign({ h: PYRAMID.h, r: PYRAMID.r }, this.shape, shape);
      this.mesh.geometry = roundedPyramid(this.shape.h, this.shape.r);
      return;
    }
    this.shape = Object.assign({}, SHAPE, { mirror: false }, this.shape, shape);
    this.mesh.geometry = new TubeGeometry(new TrefoilCurve(this.shape.a, this.shape.h), 420, this.shape.tube, 48, true);
    this.mesh.scale.set(1, 1, this.shape.mirror ? -1 : 1);
  }

  // для подбора: поза макета (ось·угол), масштаб и сдвиг центра
  setPose(rot, scale, center) {
    if (rot) this.base.setFromAxisAngle(new Vector3(...rot).normalize(), Math.hypot(...rot));
    if (scale) this.scaleK = scale;
    if (center) this.center = center;
  }

  resize() {
    const w = this.box.clientWidth;
    if (!w) return;
    const size = Math.round(w * PAD);
    this.size = w;
    this.renderer.setSize(size, size, false);
    this.canvas.style.width = size + 'px';
    this.canvas.style.height = size + 'px';
    this.camera.fov = (360 * Math.atan(size / 2 / CAMERA_Z)) / Math.PI;
    this.camera.updateProjectionMatrix();
  }

  bind() {
    let resizeTimer;
    window.addEventListener('resize', () => {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(() => this.resize(), 120);
    });

    if ('IntersectionObserver' in window) {
      new IntersectionObserver((entries) => {
        const on = entries[0].isIntersecting;
        if (on && !this.shown) {
          this.shown = true;
          this.boost = 6; // первое появление — раскрутка
        }
        if (on && !this.visible) {
          this.visible = true;
          this.last = performance.now();
          this.lastScroll = window.scrollY;
          requestAnimationFrame(this.loop);
        } else if (!on) {
          this.visible = false;
        }
      }, { rootMargin: '120px 0px' }).observe(this.box);
    }

    window.addEventListener('scroll', () => {
      const y = window.scrollY;
      const dy = y - this.lastScroll;
      this.lastScroll = y;
      if (this.visible) this.scrollV = clamp(this.scrollV + dy * 0.008, -5, 5);
    }, { passive: true });

    if (window.matchMedia('(hover: hover) and (pointer: fine)').matches) {
      window.addEventListener('pointermove', (e) => {
        if (e.pointerType !== 'mouse' || !this.visible) return;
        const r = this.box.getBoundingClientRect();
        const dx = (e.clientX - (r.left + r.width / 2)) / r.width;
        const dy = (e.clientY - (r.top + r.height / 2)) / r.height;
        this.tiltTarget.y = clamp(dx, -1.2, 1.2) * 0.45;
        this.tiltTarget.x = clamp(dy, -1.2, 1.2) * 0.35;
        this.nearTarget = clamp(1 - Math.hypot(dx, dy) / 0.9, 0, 1);
      }, { passive: true });
      document.documentElement.addEventListener('pointerleave', () => {
        this.tiltTarget.x = 0;
        this.tiltTarget.y = 0;
        this.nearTarget = 0;
      });
    }
  }

  // поза: поворот макета, внутри него — вращение вокруг оси узла (z геометрии)
  pose() {
    this.spinQ.setFromAxisAngle(this.axis, this.angle);
    this.mesh.quaternion.copy(this.base).multiply(this.spinQ);
  }

  loop(now) {
    if (!this.visible && this.ready) return;
    const dt = clamp((now - this.last) / 1000, 0, 0.05);
    this.last = now;

    this.boost *= Math.pow(0.22, dt);
    this.scrollV *= Math.pow(0.12, dt);
    this.near += (this.nearTarget - this.near) * damp(0.05, dt);
    this.tilt.x += (this.tiltTarget.x - this.tilt.x) * damp(0.06, dt);
    this.tilt.y += (this.tiltTarget.y - this.tilt.y) * damp(0.06, dt);

    if (!this.still) this.angle += (this.spin * (1 + this.near * 2.2) + this.boost + this.scrollV) * dt;
    this.pose();
    this.tiltGroup.rotation.set(this.still ? 0 : this.tilt.x, this.still ? 0 : this.tilt.y, 0);

    const t = this.still ? 0 : now / 1000;
    this.root.rotation.z = Math.sin(t * 0.45) * 0.05;
    this.root.position.set(
      this.size * this.center[0] + Math.sin(t * 0.37) * this.size * 0.012,
      this.size * this.center[1] + Math.sin(t * 0.6) * this.size * 0.02,
      0
    );
    this.root.scale.setScalar(this.size * this.scaleK);

    this.renderer.render(this.scene, this.camera);

    if (!this.ready) {
      this.ready = true;
      this.box.classList.add('is-webgl');
    }
    requestAnimationFrame(this.loop);
  }
}

function init() {
  const box = document.querySelector('[data-rd-knot]');
  if (!box) return;
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  try {
    const test = document.createElement('canvas');
    if (!(test.getContext('webgl2') || test.getContext('webgl'))) return;
    new GoldKnot(box);
  } catch (e) {
    /* без WebGL остаётся картинка */
  }
}

if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
else init();
