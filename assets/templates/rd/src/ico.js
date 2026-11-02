/*
 * Золотой икосаэдр SEO-блока главной (section 9) — WebGL, three.js r158 (тот же металл, что у спирали section 6,
 * своя «студия» под рендер макета).
 * Форма — икосаэдр со скруглёнными рёбрами (меньший икосаэдр + шар радиуса rho): грани плоские,
 * рёбра — узкие цилиндрические полоски, на них блик, как на рендере макета. Металл — как у спирали
 * (цвет, emissive), шероховатость меньше (0.2): грани ровнее, тёмные стороны темнее.
 * Поза подобрана по силуэту картинки макета (ico.webp, 600×600; совпадение силуэтов 99.5%, tools/ico_fit.py):
 * поворот ROT (ось·угол), описанная окружность острого икосаэдра — 0.3257 стороны картинки.
 *
 * Разметка: .rd-seo__obj[data-rd-ico] > .rd-seo__float > img.rd-seo__img.
 * Канвас вставляется в .rd-seo__float; после первого кадра на .rd-seo__obj ставится .is-webgl (картинка гаснет).
 * Без WebGL / при reduced motion остаётся картинка.
 *
 * Движение: медленно вращается вокруг вертикали; при первом появлении — раскрутка; прокрутка подкручивает;
 * курсор рядом — наклон к нему и быстрее вращение; лёгкое покачивание.
 */
import {
  Scene,
  PerspectiveCamera,
  WebGLRenderer,
  Group,
  Mesh,
  BufferGeometry,
  Vector3,
  Quaternion,
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
const PAD = 1.2; // канвас больше блока: наклон и покачивание не обрезаются
const SCALE = 0.3257; // описанный радиус острого икосаэдра в долях стороны блока
const ROT = [1.8951, 0.0316, -1.8071]; // поза макета: ось·угол (x вправо, y вверх, z к зрителю)
const SPIN = 0.32; // рад/с — обычное вращение
const Y_AXIS = new Vector3(0, 1, 0);

// вершины и грани — как в IcosahedronGeometry three.js
const T = (1 + Math.sqrt(5)) / 2;
const VERTS = [-1, T, 0, 1, T, 0, -1, -T, 0, 1, -T, 0, 0, -1, T, 0, 1, T, 0, -1, -T, 0, 1, -T, T, 0, -1, T, 0, 1, -T, 0, -1, -T, 0, 1];
const FACES = [0, 11, 5, 0, 5, 1, 0, 1, 7, 0, 7, 10, 0, 10, 11, 1, 5, 9, 5, 11, 4, 11, 10, 2, 10, 7, 6, 7, 1, 8,
  3, 9, 4, 3, 4, 2, 3, 2, 6, 3, 6, 8, 3, 8, 9, 4, 9, 5, 2, 4, 11, 6, 2, 10, 8, 6, 7, 9, 8, 1];
const NORMALS = [];
for (let i = 0; i < FACES.length; i += 3) {
  const n = new Vector3();
  for (let k = 0; k < 3; k++) n.add(new Vector3(VERTS[FACES[i + k] * 3], VERTS[FACES[i + k] * 3 + 1], VERTS[FACES[i + k] * 3 + 2]));
  NORMALS.push(n.normalize());
}

// «студия», которую отражает металл (x — вправо, y — вверх, z — к зрителю). Подобрано по картинке макета
// (tools/ico_look.py: средние цвета 10 видимых граней совпадают в пределах ~4 единиц): каждая плоская грань
// отражает одно направление — спереди и сверху светлый крем, справа тёмная красно-коричневая «комната»,
// сзади серо-коричневая стена, слева сзади — тёплая, внизу слева — тёмная олива; узкая полоса между
// передним и верхним светом — блик на ребре между двумя светлыми гранями.
const LIGHT = {
  room: '#2c0402',
  panels: [
    // [ширина, высота, x, y, z, яркость, цвет]
    [8, 8, 0.449, 0.449, 8.978, 2, '#ffeec8'], // спереди
    [10, 6, -3.143, 8.352, 1.167, 2, '#ffeec8'], // сверху
    [24, 24, 0.945, 0, -9.453, 1, '#5a4e46'], // стена сзади
    [10, 10, -5.398, 0.696, -6.529, 1, '#80644a'], // слева сзади
    [8, 8, -5.297, -7.182, 1.167, 1, '#423010'], // внизу слева
    [12, 10, 0.451, -5.593, -7.037, 1, '#705a48'], // внизу сзади
    [6, 4, -1.661, 5.42, 6.731, 2.2, '#fff0cc'], // блик на ребре (не белый: грань, повернувшаяся к нему, остаётся кремовой)
  ],
  dirs: [],
};

const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
const damp = (k, dt) => 1 - Math.pow(k, dt); // доля пути за dt секунд

// икосаэдр со скруглёнными рёбрами (сумма Минковского: меньший икосаэдр + шар радиуса rho):
// грани — плоские треугольники, рёбра — цилиндрические полоски, вершины — сферические «пятиугольники».
// Нормали точные — грани ровные, на рёбрах узкий блик, как на рендере макета.
const slerp = (a, b, t, out) => {
  const w = Math.acos(clamp(a.dot(b), -1, 1));
  if (w < 1e-6) return out.copy(a);
  const s = Math.sin(w);
  return out.copy(a).multiplyScalar(Math.sin((1 - t) * w) / s).addScaledVector(b, Math.sin(t * w) / s);
};

function roundedIco(rho, seg) {
  const R0 = 1 - rho; // описанный радиус внутреннего икосаэдра: снаружи вершина остаётся на расстоянии 1
  const V = [];
  for (let i = 0; i < VERTS.length; i += 3) V.push(new Vector3(VERTS[i], VERTS[i + 1], VERTS[i + 2]).normalize().multiplyScalar(R0));
  const pos = [];
  const nor = [];
  const put = (base, n) => {
    pos.push(base.x + n.x * rho, base.y + n.y * rho, base.z + n.z * rho);
    nor.push(n.x, n.y, n.z);
  };
  const tri = (b1, n1, b2, n2, b3, n3) => {
    put(b1, n1);
    put(b2, n2);
    put(b3, n3);
  };
  // грани
  const faceOf = [];
  for (let f = 0; f < FACES.length / 3; f++) {
    const [a, b, c] = [FACES[f * 3], FACES[f * 3 + 1], FACES[f * 3 + 2]];
    const n = NORMALS[f];
    tri(V[a], n, V[b], n, V[c], n);
    faceOf.push([a, b, c]);
  }
  // рёбра: у каждой пары соседних граней — полоска с дугой от нормали одной грани к нормали другой
  const edges = new Map();
  faceOf.forEach((fv, f) => {
    for (let k = 0; k < 3; k++) {
      const a = fv[k];
      const b = fv[(k + 1) % 3];
      const key = a < b ? a + '_' + b : b + '_' + a;
      if (edges.has(key)) edges.get(key).push(f, a, b);
      else edges.set(key, [f, a, b]);
    }
  });
  const p1 = new Vector3();
  const p2 = new Vector3();
  edges.forEach(([f, a, b, g]) => {
    // в грани f ребро идёт a→b (против часовой снаружи); дуга — от f к g
    for (let i = 0; i < seg; i++) {
      slerp(NORMALS[f], NORMALS[g], i / seg, p1);
      slerp(NORMALS[f], NORMALS[g], (i + 1) / seg, p2);
      const n1 = p1.clone();
      const n2 = p2.clone();
      tri(V[b], n1, V[a], n1, V[a], n2);
      tri(V[b], n1, V[a], n2, V[b], n2);
    }
  });
  // вершины: веер из центра (нормаль = направление вершины) по дугам между нормалями соседних граней
  V.forEach((v, vi) => {
    const around = faceOf.map((fv, f) => (fv.includes(vi) ? f : -1)).filter((f) => f >= 0);
    const c = v.clone().normalize();
    // упорядочить грани вокруг вершины по углу
    const ref = new Vector3().crossVectors(c, Math.abs(c.y) < 0.9 ? new Vector3(0, 1, 0) : new Vector3(1, 0, 0)).normalize();
    const ref2 = new Vector3().crossVectors(c, ref);
    around.sort((f1, f2) => Math.atan2(NORMALS[f1].dot(ref2), NORMALS[f1].dot(ref)) - Math.atan2(NORMALS[f2].dot(ref2), NORMALS[f2].dot(ref)));
    for (let k = 0; k < around.length; k++) {
      const na = NORMALS[around[k]];
      const nb = NORMALS[around[(k + 1) % around.length]];
      for (let i = 0; i < seg; i++) {
        const m1 = slerp(na, nb, i / seg, new Vector3());
        const m2 = slerp(na, nb, (i + 1) / seg, new Vector3());
        // треугольник веера: c, m1, m2 (с подразбиением к центру — сфера ровнее)
        const steps = seg;
        for (let j = 0; j < steps; j++) {
          const a1 = slerp(c, m1, j / steps, new Vector3());
          const a2 = slerp(c, m1, (j + 1) / steps, new Vector3());
          const b1 = slerp(c, m2, j / steps, new Vector3());
          const b2 = slerp(c, m2, (j + 1) / steps, new Vector3());
          tri(v, a1, v, a2, v, b2);
          if (j > 0) tri(v, a1, v, b2, v, b1);
        }
      }
    }
  });
  const g = new BufferGeometry();
  g.setAttribute('position', new Float32BufferAttribute(pos, 3));
  g.setAttribute('normal', new Float32BufferAttribute(nor, 3));
  // порядок обхода у полосок и веера — проверяем по нормали и разворачиваем треугольники, смотрящие внутрь
  const P = g.getAttribute('position');
  const N = g.getAttribute('normal');
  const e1 = new Vector3();
  const e2 = new Vector3();
  const fn = new Vector3();
  const nn = new Vector3();
  const A = new Vector3();
  const B = new Vector3();
  const C = new Vector3();
  for (let i = 0; i < P.count; i += 3) {
    A.fromBufferAttribute(P, i);
    B.fromBufferAttribute(P, i + 1);
    C.fromBufferAttribute(P, i + 2);
    fn.crossVectors(e1.subVectors(B, A), e2.subVectors(C, A));
    nn.fromBufferAttribute(N, i).add(new Vector3().fromBufferAttribute(N, i + 1)).add(new Vector3().fromBufferAttribute(N, i + 2));
    if (fn.dot(nn) < 0) {
      // поменять местами вершины 1 и 2
      for (const attr of [P, N]) {
        const x = attr.getX(i + 1), y = attr.getY(i + 1), z = attr.getZ(i + 1);
        attr.setXYZ(i + 1, attr.getX(i + 2), attr.getY(i + 2), attr.getZ(i + 2));
        attr.setXYZ(i + 2, x, y, z);
      }
    }
  }
  return g;
}

class GoldIco {
  constructor(obj, box) {
    this.obj = obj;
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
    this.still = false; // для проверки: замереть в позе макета (box.rdIco.still = true)
    box.rdIco = this;

    this.scene = new Scene();
    this.camera = new PerspectiveCamera(10, 1, 1, CAMERA_Z * 2);
    this.camera.position.set(0, 0, CAMERA_Z);

    this.renderer = new WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'low-power' });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    this.renderer.toneMapping = NoToneMapping;

    this.material = new MeshStandardMaterial({
      color: '#d0c8a8',
      metalness: 1,
      roughness: 0.2,
      envMapIntensity: 1.6,
      emissive: '#302010',
    });
    this.lights = [];
    this.setLight(LIGHT);

    this.base = new Quaternion().setFromAxisAngle(new Vector3(...ROT).normalize(), Math.hypot(...ROT));
    this.spinQ = new Quaternion();
    this.mesh = new Mesh(undefined, this.material);
    this.setShape({ rho: 0.04 });
    this.tiltGroup = new Group();
    this.tiltGroup.add(this.mesh);
    this.root = new Group();
    this.root.add(this.tiltGroup);
    this.scene.add(this.root);

    this.canvas = this.renderer.domElement;
    this.canvas.className = 'rd-seo__canvas';
    this.canvas.setAttribute('aria-hidden', 'true');
    box.appendChild(this.canvas);

    this.resize();
    this.bind();
    this.loop = this.loop.bind(this);
    requestAnimationFrame(this.loop);
  }

  // окружение (отражения) и направленный свет
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

  // rho — радиус скругления рёбер в долях описанного радиуса
  setShape(shape) {
    this.shape = shape;
    if (this.mesh.geometry) this.mesh.geometry.dispose();
    this.mesh.geometry = roundedIco(shape.rho, 6);
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
          this.shown = true;
          this.boost = 7; // первое появление — раскрутка вместе с «влётом» из CSS
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
      if (this.visible) this.scrollV = clamp(this.scrollV + dy * 0.01, -6, 6);
    }, { passive: true });

    if (window.matchMedia('(hover: hover) and (pointer: fine)').matches) {
      window.addEventListener('pointermove', (e) => {
        if (e.pointerType !== 'mouse' || !this.visible) return;
        const r = this.box.getBoundingClientRect();
        const dx = (e.clientX - (r.left + r.width / 2)) / r.width;
        const dy = (e.clientY - (r.top + r.height / 2)) / r.height;
        this.tiltTarget.y = clamp(dx, -1.2, 1.2) * 0.5;
        this.tiltTarget.x = clamp(dy, -1.2, 1.2) * 0.4;
        this.nearTarget = clamp(1 - Math.hypot(dx, dy) / 0.9, 0, 1);
      }, { passive: true });
      document.documentElement.addEventListener('pointerleave', () => {
        this.tiltTarget.x = 0;
        this.tiltTarget.y = 0;
        this.nearTarget = 0;
      });
    }
  }

  // поза: вращение вокруг вертикали поверх позы макета
  pose() {
    this.spinQ.setFromAxisAngle(Y_AXIS, this.angle);
    this.mesh.quaternion.copy(this.spinQ).multiply(this.base);
  }

  loop(now) {
    if (!this.visible && this.ready) return;
    const dt = clamp((now - this.last) / 1000, 0, 0.05);
    this.last = now;

    this.boost *= Math.pow(0.2, dt);
    this.scrollV *= Math.pow(0.12, dt);
    this.near += (this.nearTarget - this.near) * damp(0.05, dt);
    this.tilt.x += (this.tiltTarget.x - this.tilt.x) * damp(0.06, dt);
    this.tilt.y += (this.tiltTarget.y - this.tilt.y) * damp(0.06, dt);

    if (!this.still) this.angle += (SPIN * (1 + this.near * 2.5) + this.boost + this.scrollV) * dt;
    this.pose();
    this.tiltGroup.rotation.set(this.still ? 0 : this.tilt.x, this.still ? 0 : this.tilt.y, 0);

    const t = this.still ? 0 : now / 1000;
    this.root.rotation.z = Math.sin(t * 0.5) * 0.05;
    this.root.position.set(Math.sin(t * 0.37) * this.size * 0.012, Math.sin(t * 0.65) * this.size * 0.022, 0);
    this.root.scale.setScalar(this.size * SCALE);

    this.renderer.render(this.scene, this.camera);

    if (!this.ready) {
      this.ready = true;
      this.obj.classList.add('is-webgl');
    }
    requestAnimationFrame(this.loop);
  }
}

function init() {
  const obj = document.querySelector('[data-rd-ico]');
  const box = obj && obj.querySelector('.rd-seo__float');
  if (!box) return;
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  try {
    const test = document.createElement('canvas');
    if (!(test.getContext('webgl2') || test.getContext('webgl'))) return;
    new GoldIco(obj, box);
  } catch (e) {
    /* без WebGL остаётся картинка */
  }
}

if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
else init();
