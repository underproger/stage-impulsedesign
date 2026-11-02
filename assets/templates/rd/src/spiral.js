/*
 * Золотая спираль блока «Digital агентство Impulse Design» (section 6) — WebGL, three.js r158.
 * Трубка по винтовой линии со скруглёнными концами, металл с отражениями своего «студийного» окружения:
 * большой софтбокс спереди слева, слабый заполняющий справа, тёмная тёплая комната (цвета подобраны по картинке:
 * тёмные места коричневые, середина — золото, блики — светлый крем).
 * Форма подобрана по силуэту картинки макета (spiral.webp, 600×600; совпадение силуэтов 96%):
 * радиус витка 88.7, трубка 43.9, шаг 123.4 (px картинки), 2.95 витка, камера почти без перспективы;
 * на экране ось повёрнута на −60°, как картинка в макете.
 *
 * Разметка: .rd-about__obj[data-rd-3d] > .rd-about__float > img.rd-about__spiral.
 * Канвас вставляется в .rd-about__float; когда нарисован первый кадр, на .rd-about__obj ставится .is-webgl
 * (картинка гаснет). Без WebGL / при reduced motion остаётся картинка.
 *
 * Движение: спираль вращается вокруг своей оси; при появлении — раскрутка; прокрутка страницы подкручивает её
 * (вниз — вперёд, вверх — назад); курсор рядом — наклон к нему и быстрее вращение; лёгкое покачивание.
 */
import {
  Scene,
  PerspectiveCamera,
  WebGLRenderer,
  Group,
  Mesh,
  Curve,
  Vector3,
  BufferGeometry,
  Float32BufferAttribute,
  MeshStandardMaterial,
  MeshBasicMaterial,
  BoxGeometry,
  PlaneGeometry,
  Color,
  BackSide,
  DoubleSide,
  PMREMGenerator,
  DirectionalLight,
  NoToneMapping,
} from 'three';

const CAMERA_Z = 3900; // далеко — почти без перспективы, как рендер в макете
const PAD = 1.45; // канвас больше блока: наклон и покачивание не обрезаются

// размеры в долях стороны картинки
const R = 88.7 / 600;
const TUBE = 43.9 / 600;
const PITCH = 123.4 / 600;
const TURNS = 2.95;
const PHASE = 4.35; // верхний конец — слева спереди, как в макете
const TILT = 0.405; // смотрим чуть сверху: видно «нутро» витков
const ROLL = Math.PI / 3; // ось на экране повёрнута на −60° (против часовой)
const SPIN = 0.55; // рад/с — обычное вращение
const Z_AXIS = new Vector3(0, 0, 1);

// свет в системе объекта до поворота на экране (как на картинке без поворота): x — вправо, y — вверх, z — к зрителю
const LIGHT = {
  room: '#2a1c10',
  panels: [
    // [ширина, высота, x, y, z, яркость, цвет]
    [24, 24, -7, 5, 8, 1.8, '#fff4d6'], // большой софтбокс спереди слева — светлые передние грани
    [7, 1.6, 0, 5, 0.5, 1.6, '#fff1cc'], // полоса сверху
    [3, 4, 4.5, -1, 2.2, 0.25, '#ffe2a8'], // слабый заполняющий справа (правые края остаются тёмными)
  ],
  dirs: [
    // [x, y, z, яркость, цвет] — чёткий блик слева сверху
    [-1.2, 1.6, 2, 2.6, '#fff1c6'],
  ],
};

const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
const damp = (k, dt) => 1 - Math.pow(k, dt); // доля пути за dt секунд

class Helix extends Curve {
  // ext — продолжение линии за концы (доля длины), туда уходят скругления
  constructor(shape, ext = 0) {
    super();
    this.s = shape;
    this.ext = ext;
  }

  getPoint(u, target = new Vector3()) {
    const { r, pitch, turns, phase } = this.s;
    const t = -this.ext + u * (1 + 2 * this.ext);
    const a = phase + t * turns * Math.PI * 2;
    const h = pitch * turns;
    // передние витки идут слева направо и вниз — как на картинке
    return target.set(r * Math.cos(a), h / 2 - t * h, -r * Math.sin(a));
  }
}

// трубка вдоль линии с полусферами на концах (одна сетка, нормали аналитические — без швов и искр на стыках)
function capsuleTube(curve, radius, segments, radial) {
  const len = curve.getLength();
  const { tangents, normals, binormals } = curve.computeFrenetFrames(segments, false);
  const pos = [];
  const nor = [];
  const idx = [];
  const p = new Vector3();
  const rad = new Vector3();
  const n = new Vector3();
  for (let i = 0; i <= segments; i++) {
    const u = i / segments;
    curve.getPointAt(u, p);
    const s = u * len;
    // расстояние до центра скругления (0 — на цилиндрической части)
    const d = s < radius ? radius - s : s > len - radius ? -(s - (len - radius)) : 0;
    const rho = Math.sqrt(Math.max(radius * radius - d * d, 0));
    for (let j = 0; j <= radial; j++) {
      const v = (j / radial) * Math.PI * 2;
      const sin = Math.sin(v);
      const cos = -Math.cos(v);
      rad.set(0, 0, 0).addScaledVector(normals[i], cos).addScaledVector(binormals[i], sin).normalize();
      pos.push(p.x + rad.x * rho, p.y + rad.y * rho, p.z + rad.z * rho);
      // нормаль сферы на скруглении: ρ·радиус − d·касательная
      n.copy(rad).multiplyScalar(rho).addScaledVector(tangents[i], -d).normalize();
      nor.push(n.x, n.y, n.z);
    }
  }
  for (let i = 0; i < segments; i++) {
    for (let j = 0; j < radial; j++) {
      const a = i * (radial + 1) + j;
      const b = a + radial + 1;
      idx.push(a, b, a + 1, b, b + 1, a + 1);
    }
  }
  const g = new BufferGeometry();
  g.setIndex(idx);
  g.setAttribute('position', new Float32BufferAttribute(pos, 3));
  g.setAttribute('normal', new Float32BufferAttribute(nor, 3));
  return g;
}

class GoldSpiral {
  constructor(obj, box) {
    this.obj = obj;
    this.box = box;
    this.visible = true;
    this.last = performance.now();
    this.angle = 0;
    this.boost = 0; // раскрутка (рад/с), затухает
    this.scrollV = 0; // подкрутка от прокрутки (рад/с), затухает
    this.near = 0;
    this.nearTarget = 0;
    this.tilt = { x: 0, y: 0 };
    this.tiltTarget = { x: 0, y: 0 };
    this.lastScroll = window.scrollY;
    this.shown = false;
    this.still = false; // для проверки: замереть в исходной позе (box.rdSpiral.still = true)
    box.rdSpiral = this;

    this.scene = new Scene();
    this.camera = new PerspectiveCamera(10, 1, 1, CAMERA_Z * 2);
    this.camera.position.set(0, 0, CAMERA_Z);

    this.renderer = new WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'low-power' });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    this.renderer.toneMapping = NoToneMapping; // блики остаются кремовыми, а не белеют

    // цвета подобраны по картинке макета: средний цвет, доля бликов и «лесенка» тонов совпадают
    this.material = new MeshStandardMaterial({
      color: '#d0c8a8',
      metalness: 1,
      roughness: 0.3,
      envMapIntensity: 1.6,
      emissive: '#302010', // тёмные места — тёплый коричневый, не чёрный
    });
    this.pose = { roll: ROLL, tilt: TILT };
    this.lights = [];
    this.setLight(LIGHT);

    this.spiral = new Group(); // вращение вокруг своей оси
    this.setShape({ r: R, tube: TUBE, pitch: PITCH, turns: TURNS, phase: PHASE });
    this.tiltGroup = new Group(); // наклон к зрителю и к курсору
    this.tiltGroup.add(this.spiral);
    this.root = new Group(); // поворот оси на экране, покачивание, масштаб
    this.root.add(this.tiltGroup);
    this.scene.add(this.root);

    this.canvas = this.renderer.domElement;
    this.canvas.className = 'rd-about__canvas';
    this.canvas.setAttribute('aria-hidden', 'true');
    box.appendChild(this.canvas);

    this.resize();
    this.bind();
    this.loop = this.loop.bind(this);
    requestAnimationFrame(this.loop);
  }

  // окружение (отражения) и направленный свет; всё повёрнуто вместе с осью спирали
  setLight(light) {
    this.light = light;
    const turn = (x, y, z) => new Vector3(x, y, z).applyAxisAngle(Z_AXIS, this.pose.roll);

    const env = new Scene();
    env.add(new Mesh(new BoxGeometry(40, 40, 40), new MeshBasicMaterial({ color: light.room, side: BackSide })));
    light.panels.forEach(([w, h, x, y, z, k, c]) => {
      const m = new Mesh(new PlaneGeometry(w, h), new MeshBasicMaterial({ color: new Color(c).multiplyScalar(k), side: DoubleSide }));
      m.position.copy(turn(x, y, z));
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
      l.position.copy(turn(x, y, z));
      this.scene.add(l);
      return l;
    });
  }

  // трубка по винтовой линии + сферы на концах (размеры — в долях стороны блока)
  setShape(shape) {
    this.shape = shape;
    this.spiral.children.slice().forEach((m) => {
      this.spiral.remove(m);
      m.geometry.dispose();
    });
    const hi = window.matchMedia('(min-width: 1200px)').matches;
    // линию продлеваем на радиус трубки с каждой стороны — скругления не «съедают» длину
    const base = new Helix(shape);
    const curve = new Helix(shape, shape.tube / base.getLength());
    this.spiral.add(new Mesh(capsuleTube(curve, shape.tube, hi ? 700 : 420, hi ? 48 : 32), this.material));
  }

  resize() {
    const w = this.box.clientWidth;
    if (!w) return;
    const size = Math.round(w * PAD);
    this.size = w;
    this.renderer.setSize(size, size, false);
    this.canvas.style.width = size + 'px';
    this.canvas.style.height = size + 'px';
    // 1 единица сцены = 1 css-пиксель на плоскости z = 0
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
          // первое появление — раскрутка вместе с «влётом» из CSS
          this.shown = true;
          this.boost = 9;
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

    // прокрутка подкручивает спираль (знак — направление)
    window.addEventListener('scroll', () => {
      const y = window.scrollY;
      const dy = y - this.lastScroll;
      this.lastScroll = y;
      if (this.visible) this.scrollV = clamp(this.scrollV + dy * 0.012, -8, 8);
    }, { passive: true });

    // курсор: наклон к нему, рядом — вращается быстрее
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

  loop(now) {
    // первый кадр рисуем всегда — к моменту прокрутки до блока 3D уже подменило картинку
    if (!this.visible && this.ready) return;
    const dt = clamp((now - this.last) / 1000, 0, 0.05);
    this.last = now;

    this.boost *= Math.pow(0.22, dt);
    this.scrollV *= Math.pow(0.12, dt);
    this.near += (this.nearTarget - this.near) * damp(0.05, dt);
    this.tilt.x += (this.tiltTarget.x - this.tilt.x) * damp(0.06, dt);
    this.tilt.y += (this.tiltTarget.y - this.tilt.y) * damp(0.06, dt);

    if (!this.still) this.angle += (SPIN * (1 + this.near * 2.2) + this.boost + this.scrollV) * dt;
    this.spiral.rotation.y = this.angle;
    this.tiltGroup.rotation.set(this.pose.tilt + this.tilt.x, this.tilt.y, 0);

    const t = this.still ? 0 : now / 1000;
    this.root.rotation.z = this.pose.roll + Math.sin(t * 0.55) * 0.07;
    this.root.position.set(Math.sin(t * 0.4) * this.size * 0.012, Math.sin(t * 0.7) * this.size * 0.02, 0);
    this.root.scale.setScalar(this.size);

    this.renderer.render(this.scene, this.camera);

    if (!this.ready) {
      this.ready = true;
      this.obj.classList.add('is-webgl');
    }
    requestAnimationFrame(this.loop);
  }
}

function init() {
  const obj = document.querySelector('[data-rd-3d]');
  const box = obj && obj.querySelector('.rd-about__float');
  if (!box) return;
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  try {
    const test = document.createElement('canvas');
    if (!(test.getContext('webgl2') || test.getContext('webgl'))) return;
    new GoldSpiral(obj, box);
  } catch (e) {
    /* без WebGL остаётся картинка */
  }
}

if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
else init();
