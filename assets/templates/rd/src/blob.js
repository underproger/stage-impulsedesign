/*
 * Золотой объект первого экрана (WebGL, three.js r158).
 * Порт анимации из прототипа: сфера, деформированная шумом Перлина, золотой Phong-материал.
 *
 * Сборка (из каталога с node_modules three@0.158.0 и esbuild):
 *   npx esbuild assets/templates/rd/src/blob.js --bundle --minify --format=iife \
 *     --target=es2018 --outfile=assets/templates/rd/js/rd-blob.js
 *
 * Разметка: .rd-hero__glob (обёртка с PNG-заглушкой) — канвас вставляется внутрь.
 * Пока WebGL не нарисовал первый кадр, видна PNG; без WebGL / при reduced motion остаётся PNG.
 */
import {
  Scene,
  PerspectiveCamera,
  WebGLRenderer,
  Object3D,
  Mesh,
  IcosahedronGeometry,
  MeshPhongMaterial,
  DirectionalLight,
  AmbientLight,
} from 'three';
import { vertexPars, vertexMain, fragmentPars, fragmentMain } from './blob-glsl.js';

const CAMERA_Z = 1000;
const SCALE = 0.3; // радиус сферы = 30% ширины блока (как в прототипе)
const CANVAS_PAD = 1.4; // канвас больше блока, чтобы деформация не обрезалась

class GoldBlob {
  constructor(box) {
    this.box = box;
    this.start = performance.now();
    this.last = this.start;
    this.visible = true;
    this.uniforms = {
      uAlpha: { value: 1 },
      uTime: { value: 0 },
      uScale: { value: 1 },
    };

    this.scene = new Scene();
    this.parent = new Object3D();
    this.scene.add(this.parent);

    this.camera = new PerspectiveCamera(45, 1, 1, 2000);
    this.camera.position.set(0, 0, CAMERA_Z);

    const light = { color: '#d2c880', intensity: 0.6 };
    const dir1 = new DirectionalLight(light.color, light.intensity);
    const dir2 = new DirectionalLight(light.color, light.intensity);
    dir1.position.set(-2, 0, 2);
    dir2.position.set(0, 2, 2);
    this.scene.add(dir1, dir2, new AmbientLight('#ffdc00', 0));

    this.renderer = new WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'low-power' });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    this.canvas = this.renderer.domElement;
    this.canvas.className = 'rd-hero__canvas';
    this.canvas.setAttribute('aria-hidden', 'true');
    box.appendChild(this.canvas);

    const isDesktop = window.matchMedia('(min-width: 1200px)').matches;
    const detail = isDesktop ? 50 : 26;

    this.mesh = new Mesh(new IcosahedronGeometry(1, detail), this.material());
    this.parent.add(this.mesh);

    this.resize();
    this.bind();
    this.loop = this.loop.bind(this);
    requestAnimationFrame(this.loop);
  }

  material() {
    const uniforms = this.uniforms;
    const material = new MeshPhongMaterial({
      shininess: 31.4,
      color: '#afa37d',
      specular: '#f7f7f7',
      emissive: '#37200d',
    });
    material.onBeforeCompile = (shader) => {
      shader.uniforms.uTime = uniforms.uTime;
      shader.uniforms.uAlpha = uniforms.uAlpha;
      shader.uniforms.uScale = uniforms.uScale;
      shader.vertexShader = shader.vertexShader
        .replace('#include <displacementmap_pars_vertex>', '#include <displacementmap_pars_vertex>\n' + vertexPars)
        .replace('#include <displacementmap_vertex>', '#include <displacementmap_vertex>\n' + vertexMain);
      shader.fragmentShader = shader.fragmentShader
        .replace('#include <bumpmap_pars_fragment>', '#include <bumpmap_pars_fragment>\n' + fragmentPars)
        .replace('#include <normal_fragment_maps>', '#include <normal_fragment_maps>\n' + fragmentMain);
    };
    return material;
  }

  resize() {
    const w = this.box.clientWidth;
    if (!w) return;
    const size = Math.round(w * CANVAS_PAD);
    this.size = w;
    this.renderer.setSize(size, size, false);
    this.canvas.style.width = size + 'px';
    this.canvas.style.height = size + 'px';
    // 1 единица сцены = 1 css-пиксель на плоскости z = 0
    this.camera.fov = (360 * Math.atan(size / 2 / CAMERA_Z)) / Math.PI;
    this.camera.aspect = 1;
    this.camera.updateProjectionMatrix();
    this.uniforms.uScale.value = w * SCALE;
  }

  bind() {
    let resizeTimer;
    window.addEventListener('resize', () => {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(() => this.resize(), 120);
    });

    // Пауза, когда объект за пределами экрана
    if ('IntersectionObserver' in window) {
      new IntersectionObserver((entries) => {
        this.visible = entries[0].isIntersecting;
        if (this.visible) {
          this.last = performance.now();
          requestAnimationFrame(this.loop);
        }
      }).observe(this.box);
    }
  }

  loop(now) {
    if (!this.visible) return;
    const dt = Math.min((now - this.last) / 16.667, 3); // в «кадрах 60fps»
    this.last = now;

    this.uniforms.uTime.value = 0.00025 * (now - this.start);
    this.mesh.scale.setScalar(this.size * SCALE);
    this.mesh.rotation.y += 0.01 * dt;

    this.renderer.render(this.scene, this.camera);

    if (!this.ready) {
      this.ready = true;
      this.box.classList.add('is-webgl');
    }
    requestAnimationFrame(this.loop);
  }
}

function init() {
  const box = document.querySelector('[data-rd-glob]');
  if (!box) return;
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  try {
    const test = document.createElement('canvas');
    if (!(test.getContext('webgl2') || test.getContext('webgl'))) return;
    new GoldBlob(box);
  } catch (e) {
    /* без WebGL остаётся PNG */
  }
}

if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
else init();
