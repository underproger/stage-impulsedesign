/*
 * Жидкое золото первого экрана главной ([data-rd-glob]). Чистый WebGL1, без three.js.
 *
 * Фигура — поле расстояний (SDF), рисуется трассировкой лучей (raymarching) в одном фрагментном шейдере
 * на полноэкранном треугольнике: закрученная «трилистником» капля — три лопасти вокруг вертикали,
 * скрученные по высоте, дают спиральные складки, как у драпировки; лопасти медленно «перетекают».
 * Материал — золото (Френель Шлика) с отражением тёмной студии: большой мягкий софтбокс сверху-слева,
 * узкие полосы по рёбрам, контровые сзади, тёплый отсвет «планеты» снизу.
 * Вокруг — тонкая золотая орбита (аналитически: расстояние от луча до окружности) и два золотых шарика
 * (аналитическое пересечение со сферой); задняя половина орбиты прячется за фигурой.
 *
 * Интерактив: наклон сцены к курсору, «волнение» от скорости мыши (быстрее перетекает и рябит).
 * Клик / тап по объекту: в точке касания — вмятина и золотая вспышка, от неё по поверхности бежит кольцевая волна
 * (до 4 волн сразу, каждая со своей частотой и силой), плюс один из «характеров» по очереди без повторов:
 * желе (сжатие вдоль касания и пружинящий отскок), закрутка спиралью, капля (из фигуры в сторону клика
 * вытягивается капля на «шейке», отрывается и возвращается — гладкое объединение двух полей), вихрь (фигура и шарики раскручиваются в сторону удара, орбита покачивается). Частые клики
 * (4 за ~0.7 с между ними) — «шторм»: всё сразу и сильнее, шарики делают лишний круг.
 * Появление: фигура вырастает, орбита прочерчивается.
 * Пауза вне экрана (IntersectionObserver) и в фоновой вкладке; разрешение буфера подстраивается под
 * скорость видеокарты (меньше 45 кадров/с — буфер мельче, канвас растягивается CSS; потолок ~1 Мп / 0.45 Мп на мобильных).
 *
 * Разметка: .rd-hero__glob (обёртка с картинкой-заглушкой) — канвас вставляется внутрь и занимает её целиком.
 * Пока WebGL не нарисовал первый кадр, видна картинка; без WebGL / при reduced motion остаётся картинка.
 * Картинка-заглушка (hero-liquid.webp/png) снята с этого же шейдера (кадр при ?rd-liquid-still).
 */

const VS = 'attribute vec2 a;varying vec2 vUv;void main(){vUv=a*0.5+0.5;gl_Position=vec4(a,0.0,1.0);}';

const FS = `
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
uniform vec2 uRes;
uniform float uTime;
uniform vec2 uSpin;
uniform vec2 uTilt;
uniform float uAgit;
uniform float uPulse;
uniform float uGrow;
uniform float uReveal;
uniform vec3 uRingU;
uniform vec3 uRingV;
uniform vec3 uBall1;
uniform vec3 uBall2;
uniform vec4 uHit[4];   // удары: xyz — точка касания (направление в координатах фигуры), w — возраст волны, с
uniform vec2 uHitP[4];  // x — сила (0 — слот пуст), y — частота волны
uniform vec4 uSquash;   // желе: xyz — ось (вдоль касания), w — сжатие (пружина, ±)
uniform float uTwist;   // доп. закрутка спиралью (пружина)
uniform vec4 uDrop;     // капля: xyz — точка поверхности, откуда вылетает (в координатах фигуры), w — вылет (0 — капли нет)
uniform float uRingGlow; // вспышка орбиты
varying vec2 vUv;

#define RING_R 1.62
#define BALL_R 0.068
#define BOUND 1.50
#define ZOOM 0.70

mat2 rot(float a){ float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }
float lobe(vec3 n, vec3 L, float k){ return pow(max(dot(n, normalize(L)), 0.0), k); }

// закрученная «трилистником» капля (координаты фигуры)
// волна от удара: кольцо бежит от точки касания по поверхности (g — хорда до точки, 0..2), в точке — вмятина
float ripple(vec3 np, out float slope){
  float rip = 0.0;
  slope = 0.0;
  for(int i = 0; i < 4; i++){
    float A = uHitP[i].x;
    if(A > 0.001){
      float age = uHit[i].w;
      float g = length(np - uHit[i].xyz);
      float x = g - age*1.05;
      float fade = exp(-age*1.25);
      rip += A*(0.075*fade*sin(uHitP[i].y*x)*exp(-x*x*12.0) - 0.13*exp(-g*g*26.0)*exp(-age*4.5));
      slope += A*fade*uHitP[i].y*0.075 + A*0.6*exp(-age*4.5);
    }
  }
  return rip;
}

float sculpt(vec3 p){
  float t = uTime;
  float s1 = sin(t*0.45), s2 = sin(t*0.37 + 1.3), s3 = sin(t*0.29 + 2.1);
  vec3 np = p / max(length(p), 1e-4); // направление в координатах фигуры (до закрутки) — к нему привязаны удары
  // желе: сжатие вдоль оси касания, расширение поперёк (объём «сохраняется»)
  float sq = uSquash.w;
  vec3 ax = uSquash.xyz;
  float pa = dot(p, ax);
  p += ax*pa*sq - (p - ax*pa)*sq*0.45;
  vec3 q = p / uGrow / vec3(0.93, 1.08, 0.93);
  q.xy *= rot(0.35);
  q.xz *= rot(q.y*(1.25 + 0.25*s1 + uTwist) + t*0.15 + uTwist*0.5);
  q += (0.05 + 0.05*uAgit)*sin(q.yzx*2.6 + vec3(t*0.5, t*0.4, t*0.6));
  float r = length(q);
  vec3 n = q / max(r, 1e-4);
  float tri = n.x*n.x*n.x - 3.0*n.x*n.z*n.z;
  float quad = (n.x*n.x - n.z*n.z) * n.y;
  float R = 0.86 + 0.40*tri + 0.18*quad
          + 0.30*lobe(n, vec3(-0.3 + 0.1*s2, 1.0, 0.2), 4.0)
          + 0.16*lobe(n, vec3(0.1, -1.0, 0.1 + 0.2*s3), 3.0)
          + (0.04 + 0.03*uAgit)*sin(5.0*n.x + 4.0*n.y + t*0.8)*sin(4.0*n.z - t*0.6)
          + uPulse*0.05*sin(9.0*n.y + 6.0*n.x - t*9.0);
  float slope;
  R += ripple(np, slope);
  // деформации увеличивают «крутизну» поля — шаг луча меньше, чтобы не проскочить поверхность
  float lip = 1.0 + abs(sq)*1.2 + abs(uTwist)*0.9 + slope*0.9;
  float d = (r - R) * 0.39 * uGrow / lip;
  // капля: шарик вылетает из поверхности и возвращается; гладкое объединение — «шейка», пока он близко
  if(uDrop.w > 0.001){
    float e = uDrop.w;
    vec3 dn = normalize(uDrop.xyz);
    float rb = (0.25 - 0.08*e)*uGrow;
    vec3 c = uDrop.xyz + dn*(e*uGrow - rb*0.7);
    float ds = (length(p - c) - rb)*0.8;
    float k = 0.26*uGrow*(1.0 - 0.6*smoothstep(0.2, 0.7, e));
    float hh = clamp(0.5 + 0.5*(ds - d)/k, 0.0, 1.0);
    d = mix(ds, d, hh) - k*hh*(1.0 - hh);
  }
  return d;
}

// вспышка в точке удара и блик на гребне волны (для пикселя поверхности)
float hitGlow(vec3 np){
  float f = 0.0;
  for(int i = 0; i < 4; i++){
    float A = uHitP[i].x;
    if(A > 0.001){
      float age = uHit[i].w;
      float g = length(np - uHit[i].xyz);
      float x = g - age*1.05;
      f += A*(0.9*exp(-g*g*30.0)*exp(-age*3.5) + 0.22*exp(-x*x*90.0)*exp(-age*1.6));
    }
  }
  return f;
}

// мир → фигура: фигура вращается вокруг вертикали
float map(vec3 p){
  p.xz = mat2(uSpin.x, -uSpin.y, uSpin.y, uSpin.x) * p.xz;
  return sculpt(p);
}

vec3 calcNormal(vec3 p){
  const vec2 k = vec2(1.0, -1.0);
  const float h = 0.0015;
  return normalize(k.xyy*map(p + k.xyy*h) + k.yyx*map(p + k.yyx*h) + k.yxy*map(p + k.yxy*h) + k.xxx*map(p + k.xxx*h));
}

float calcAO(vec3 p, vec3 n){
  float occ = 0.0, sca = 1.0;
  for(int i = 0; i < 4; i++){
    float h = 0.03 + 0.06*float(i);
    occ += (h - map(p + h*n))*sca;
    sca *= 0.85;
  }
  return clamp(1.0 - 2.0*occ, 0.0, 1.0);
}

// прямоугольный софтбокс в направлении c
float box(vec3 d, vec3 c, vec3 u, float w, float h, float soft){
  float k = dot(d, c);
  if(k <= 0.0) return 0.0;
  vec3 v = cross(c, u);
  vec2 e = vec2(dot(d, u), dot(d, v)) / k;
  vec2 a = abs(e) - vec2(w, h);
  return 1.0 - smoothstep(-soft, soft, max(a.x, a.y));
}

vec3 env(vec3 d){
  vec3 c = vec3(0.002, 0.0018, 0.0015) + vec3(0.012, 0.010, 0.008)*smoothstep(-0.1, 0.9, d.y);
  c += vec3(3.0, 2.8, 2.4) * box(d, normalize(vec3(-0.6, 0.6, 0.55)), normalize(vec3(0.7, 0.0, 0.7)), 0.95, 0.55, 0.45);
  c += vec3(0.30, 0.27, 0.22) * smoothstep(0.0, 1.0, d.y);
  c += vec3(1.6, 1.45, 1.2) * box(d, normalize(vec3(0.15, 1.0, 0.0)), vec3(1.0, 0.0, 0.0), 1.3, 0.10, 0.04);
  c += vec3(3.0, 2.7, 2.2) * box(d, normalize(vec3(1.0, 0.15, 0.2)), normalize(vec3(-0.2, 0.0, 1.0)), 0.05, 0.9, 0.02);
  c += vec3(2.0, 1.8, 1.5) * box(d, normalize(vec3(-1.0, 0.1, -0.5)), normalize(vec3(0.5, 0.0, -1.0)), 0.06, 0.8, 0.02);
  c += vec3(1.8, 1.55, 1.2) * box(d, normalize(vec3(0.5, 0.45, -1.0)), normalize(vec3(1.0, 0.0, 0.5)), 0.35, 0.18, 0.06);
  c += vec3(1.2, 1.0, 0.8) * box(d, normalize(vec3(-0.6, -0.1, -1.0)), normalize(vec3(1.0, 0.0, -0.6)), 0.2, 0.3, 0.08);
  c += vec3(0.9, 0.62, 0.30) * smoothstep(0.08, 0.0, abs(d.y + 0.30)) * smoothstep(-0.6, 0.4, d.z);
  c += vec3(0.30, 0.20, 0.08) * box(d, normalize(vec3(0.1, -0.75, 0.65)), vec3(1.0, 0.0, 0.0), 0.9, 0.35, 0.5);
  c += vec3(1.4, 1.1, 0.7) * box(d, normalize(vec3(-0.7, -0.45, 0.55)), normalize(vec3(0.6, 0.0, 0.8)), 0.12, 0.05, 0.03);
  c += vec3(1.1, 1.0, 0.85) * box(d, normalize(vec3(0.15, 0.45, 1.0)), normalize(vec3(1.0, 0.0, -0.15)), 0.7, 0.35, 0.45);
  return c;
}

// золото: отражение студии с Френелем, мягкое тонирование
vec3 gold(vec3 rd, vec3 n, float ao){
  vec3 F0 = vec3(1.0, 0.78, 0.42);
  float ndv = clamp(dot(n, -rd), 0.0, 1.0);
  vec3 F = F0 + (1.0 - F0)*pow(1.0 - ndv, 5.0);
  vec3 c = env(reflect(rd, n)) * F * mix(0.15, 1.0, ao*ao) * 2.0;
  float L = dot(c, vec3(0.3, 0.55, 0.15));
  c = c / (1.0 + L) * (1.0 + L/6.0);
  return pow(clamp(c, 0.0, 1.0), vec3(1.0/2.2));
}

// шарик: аналитическое пересечение; xy — t попадания (или -1), z — покрытие края
vec3 ball(vec3 ro, vec3 rd, vec3 c, float pix){
  vec3 oc = ro - c;
  float b = dot(oc, rd);
  float tc = -b;
  float dist = length(oc + rd*tc);
  float cov = 1.0 - smoothstep(BALL_R - pix*tc, BALL_R + pix*tc, dist);
  float h = BALL_R*BALL_R - dist*dist;
  float th = h > 0.0 ? tc - sqrt(h) : tc;
  return vec3(th, cov, 0.0);
}

void main(){
  vec2 uv = vUv*2.0 - 1.0;
  uv.x *= uRes.x / uRes.y;
  float pix = 2.0*ZOOM / 1.6 / uRes.y; // угловой размер пикселя
  vec3 ro = vec3(0.0, 0.0, 4.2);
  vec3 rd = normalize(vec3(uv*ZOOM, -1.6));
  mat2 rx = rot(uTilt.y), ry = rot(uTilt.x);
  ro.yz *= rx; rd.yz *= rx;
  ro.xz *= ry; rd.xz *= ry;

  // фигура
  vec4 col = vec4(0.0);
  float tHit = 1e5;
  float b = dot(ro, rd);
  float bound = uDrop.w > 0.001 ? max(BOUND, length(uDrop.xyz) + uDrop.w + 0.25) : BOUND; // вылетевшая капля — дальше обычной границы
  float h = b*b - dot(ro, ro) + bound*bound;
  if(h > 0.0){
    float sq = sqrt(h);
    float t = max(-b - sq, 0.0);
    float tmax = -b + sq;
    float md = 1e5;
    bool hit = false;
    for(int i = 0; i < 100; i++){
      float d = map(ro + rd*t);
      md = min(md, d / (0.39*t));
      if(d < 0.0004*t){ hit = true; break; }
      t += d;
      if(t > tmax) break;
    }
    if(hit){
      vec3 p = ro + rd*t;
      vec3 n = calcNormal(p);
      col = vec4(gold(rd, n, calcAO(p, n)), 1.0);
      // вспышка удара: точка попадания в координатах фигуры (как в map)
      vec3 pf = p;
      pf.xz = mat2(uSpin.x, -uSpin.y, uSpin.y, uSpin.x) * pf.xz;
      float hg = hitGlow(normalize(pf));
      col.rgb += vec3(1.0, 0.82, 0.48)*hg*(0.6 + 0.4*col.rgb);
      tHit = t;
    } else {
      // сглаживание силуэта: луч прошёл совсем рядом — частичное покрытие
      float a = 1.0 - smoothstep(0.0, 1.5*pix, md);
      if(a > 0.0){
        vec3 p = ro + rd*t;
        col = vec4(gold(rd, calcNormal(p), 1.0), a);
        tHit = t;
      }
    }
  }

  // шарики
  for(int k = 0; k < 2; k++){
    vec3 c = k == 0 ? uBall1 : uBall2;
    vec3 bb = ball(ro, rd, c, pix);
    if(bb.y > 0.001 && bb.x < tHit){
      vec3 p = ro + rd*bb.x;
      vec3 n = normalize(p - c);
      vec3 g = gold(rd, n, 1.0);
      col = vec4(mix(col.rgb, g, bb.y), max(col.a, bb.y));
      if(bb.y > 0.5) tHit = bb.x;
    }
  }

  // орбита: расстояние от луча до окружности (попеременные проекции)
  vec3 N = normalize(cross(uRingU, uRingV));
  float dn = dot(rd, N);
  float tp = abs(dn) > 1e-3 ? -dot(ro, N)/dn : -b;
  vec3 P = ro + rd*max(tp, 0.0);
  vec3 C = vec3(0.0);
  float tc = 0.0;
  for(int i = 0; i < 3; i++){
    vec3 Pp = P - N*dot(P, N);
    C = normalize(Pp + 1e-5)*RING_R;
    tc = dot(C - ro, rd);
    P = ro + rd*tc;
  }
  float dist = length(P - C);
  float w = pix*tc*0.75;
  float line = 1.0 - smoothstep(w*0.5, w*1.8, dist);
  float glow = exp(-dist/(pix*tc*7.0))*0.22*(1.0 + uRingGlow*2.5);
  // прорисовка при появлении: дуга растёт от левого шарика
  float ang = fract(atan(dot(C, uRingV), dot(C, uRingU))/6.2831853 + 0.5);
  float rev = 1.0 - smoothstep(uReveal - 0.02, uReveal, ang);
  float ring = (line + glow) * rev;
  // дальняя половина темнее
  float lit = 0.5 + 0.5*dot(C/RING_R, normalize(vec3(-0.5, 0.75, 0.45)));
  float front = smoothstep(-0.6, 0.6, C.z/RING_R);
  vec3 rc = mix(vec3(0.45, 0.33, 0.14), vec3(1.0, 0.86, 0.55), lit) * mix(0.55, 1.0, front) * (1.0 + uRingGlow*0.6);
  if(tc < tHit){
    col.rgb = mix(col.rgb, rc, clamp(ring, 0.0, 1.0));
    col.a = max(col.a, clamp(ring, 0.0, 1.0));
  } else {
    float a = clamp(ring, 0.0, 1.0) * (1.0 - col.a);
    col.rgb = mix(col.rgb, rc, a / max(col.a + a, 1e-4));
    col.a += a;
  }

  gl_FragColor = vec4(col.rgb*col.a, col.a);
}
`;

const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
const easeOutBack = (t) => 1 + 2.2 * Math.pow(t - 1, 3) + 1.2 * Math.pow(t - 1, 2);
const easeOutExpo = (t) => (t >= 1 ? 1 : 1 - Math.pow(2, -10 * t));
const norm = (v) => {
  const l = Math.hypot(v[0], v[1], v[2]);
  return [v[0] / l, v[1] / l, v[2] / l];
};
const cross = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];

// плоскость орбиты: большая ось — снизу-слева вверх-вправо, наклон к зрителю (как в макете)
const RING_N = norm([-0.58, 0.56, 0.62]);
const RING_U = norm(cross([0, 0, 1], RING_N)); // в плоскости, «горизонталь» орбиты
const RING_V = cross(RING_N, RING_U);
const RING_R = 1.62;
const HITS = 4; // волн от ударов одновременно

// поворот вектора v вокруг единичной оси k на угол a (Родриг)
const rotAxis = (v, k, a) => {
  const c = Math.cos(a);
  const s = Math.sin(a);
  const d = (v[0] * k[0] + v[1] * k[1] + v[2] * k[2]) * (1 - c);
  const x = cross(k, v);
  return [v[0] * c + x[0] * s + k[0] * d, v[1] * c + x[1] * s + k[1] * d, v[2] * c + x[2] * s + k[2] * d];
};

// пружина с затуханием: x — отклонение, v — скорость; k — жёсткость, c — вязкость (dt в секундах)
const spring = (o, k, c, dt) => {
  o.v += (-k * o.x - c * o.v) * dt;
  o.x += o.v * dt;
  if (Math.abs(o.x) < 1e-4 && Math.abs(o.v) < 1e-3) { o.x = 0; o.v = 0; }
};

// форма фигуры на JS (как sculpt в шейдере, без волн и желе): r − R для точки p в координатах фигуры —
// по ней ищется поверхность в направлении капли (капля вылетает из самой поверхности)
const shapeF = (p, st) => {
  const t = st.time;
  const s1 = Math.sin(t * 0.45);
  const s2 = Math.sin(t * 0.37 + 1.3);
  const s3 = Math.sin(t * 0.29 + 2.1);
  let x = p[0] / st.grow / 0.93;
  let y = p[1] / st.grow / 1.08;
  let z = p[2] / st.grow / 0.93;
  let c = Math.cos(0.35);
  let s = Math.sin(0.35);
  [x, y] = [c * x - s * y, s * x + c * y];
  const a = y * (1.25 + 0.25 * s1 + st.twist) + t * 0.15 + st.twist * 0.5;
  c = Math.cos(a);
  s = Math.sin(a);
  [x, z] = [c * x - s * z, s * x + c * z];
  const amp = 0.05 + 0.05 * st.agit;
  const nx = x + amp * Math.sin(y * 2.6 + t * 0.5);
  const ny = y + amp * Math.sin(z * 2.6 + t * 0.4);
  const nz = z + amp * Math.sin(nx * 2.6 + t * 0.6);
  x = nx; y = ny; z = nz;
  const r = Math.hypot(x, y, z) || 1e-4;
  const n = [x / r, y / r, z / r];
  const lobe = (L, k) => {
    const l = Math.hypot(L[0], L[1], L[2]);
    return Math.pow(Math.max((n[0] * L[0] + n[1] * L[1] + n[2] * L[2]) / l, 0), k);
  };
  const R = 0.86 + 0.40 * (n[0] ** 3 - 3 * n[0] * n[2] * n[2]) + 0.18 * (n[0] * n[0] - n[2] * n[2]) * n[1]
    + 0.30 * lobe([-0.3 + 0.1 * s2, 1.0, 0.2], 4) + 0.16 * lobe([0.1, -1.0, 0.1 + 0.2 * s3], 3)
    + (0.04 + 0.03 * st.agit) * Math.sin(5 * n[0] + 4 * n[1] + t * 0.8) * Math.sin(4 * n[2] - t * 0.6);
  return r - R;
};

// «характеры» клика — по очереди из перемешанного набора, без повтора подряд
const MOODS = ['jelly', 'twist', 'drop', 'whirl'];

class LiquidGold {
  constructor(box, still) {
    this.box = box;
    this.still = still; // { t, spin, orbit, scale } — статичный кадр для заглушки
    const canvas = document.createElement('canvas');
    canvas.className = 'rd-hero__canvas';
    canvas.setAttribute('aria-hidden', 'true');
    const opts = { alpha: true, antialias: false, depth: false, stencil: false, premultipliedAlpha: true, powerPreference: 'high-performance', preserveDrawingBuffer: !!still };
    const gl = canvas.getContext('webgl', opts) || canvas.getContext('experimental-webgl', opts);
    if (!gl) throw new Error('no webgl');
    this.gl = gl;
    this.canvas = canvas;

    const prog = this.program(VS, FS);
    gl.useProgram(prog);
    const buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW);
    const loc = gl.getAttribLocation(prog, 'a');
    gl.enableVertexAttribArray(loc);
    gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);
    this.u = {};
    ['uRes', 'uTime', 'uSpin', 'uTilt', 'uAgit', 'uPulse', 'uGrow', 'uReveal', 'uRingU', 'uRingV', 'uBall1', 'uBall2',
      'uHit', 'uHitP', 'uSquash', 'uTwist', 'uDrop', 'uRingGlow'].forEach((n) => {
      this.u[n] = gl.getUniformLocation(prog, n);
    });
    gl.uniform3fv(this.u.uRingU, RING_U);
    gl.uniform3fv(this.u.uRingV, RING_V);

    // состояние
    this.start = performance.now();
    this.last = this.start;
    this.time = 0;
    this.spin = 0.6;
    this.orbit = 0;
    this.agit = 0;
    this.agitTarget = 0;
    this.pulse = 0;
    this.tilt = { x: 0, y: 0 };
    this.tiltTarget = { x: 0, y: 0 };
    this.lastMove = null;
    // клик: волны (слоты), пружины «характеров», раскрутка, вспышка орбиты
    this.hits = [];
    for (let i = 0; i < HITS; i++) this.hits.push({ n: [0, 0, 1], age: 0, a: 0, f: 18 });
    this.hitBuf = new Float32Array(HITS * 4);
    this.hitPBuf = new Float32Array(HITS * 2);
    this.squash = { x: 0, v: 0, ax: [0, 0, 1] };
    this.twist = { x: 0, v: 0 };
    this.drop = { x: 0, v: 0, dir: [0, 0, 1] };
    this.ringTilt = { x: 0, v: 0 };
    this.ringAxis = RING_U;
    this.spinVel = 0;
    this.orbitVel = 0;
    this.ringGlow = 0;
    this.moods = [];
    this.lastMood = '';
    this.taps = [];
    this.visible = true;
    this.running = false;
    // качество: доля devicePixelRatio, снижается, если кадры медленные
    this.dpr = Math.min(window.devicePixelRatio || 1, 2);
    this.quality = 1;
    this.frames = [];

    box.appendChild(canvas);
    box.rdLiquid = this; // для проверок (tools/hero_tap.py)
    this.resize();
    if (still) {
      this.render(performance.now());
      box.classList.add('is-webgl');
      return;
    }
    this.bind();
    this.loop = this.loop.bind(this);
    this.play();
  }

  program(vs, fs) {
    const gl = this.gl;
    const sh = (type, src) => {
      const s = gl.createShader(type);
      gl.shaderSource(s, src);
      gl.compileShader(s);
      if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) throw new Error(gl.getShaderInfoLog(s));
      return s;
    };
    const p = gl.createProgram();
    gl.attachShader(p, sh(gl.VERTEX_SHADER, vs));
    gl.attachShader(p, sh(gl.FRAGMENT_SHADER, fs));
    gl.linkProgram(p);
    if (!gl.getProgramParameter(p, gl.LINK_STATUS)) throw new Error(gl.getProgramInfoLog(p));
    return p;
  }

  resize() {
    const w = this.box.clientWidth;
    const h = this.box.clientHeight || w;
    if (!w) return;
    // бюджет пикселей буфера: ~1 Мп на десктопе, ~0.45 Мп на телефоне/планшете (дальше — растягивание CSS)
    const budget = window.innerWidth >= 1200 ? 1.0e6 : 4.5e5;
    const k = this.still ? this.still.scale || 1 : Math.min(this.dpr * this.quality, Math.sqrt(budget / (w * h)));
    const bw = Math.max(1, Math.round(w * k));
    const bh = Math.max(1, Math.round(h * k));
    if (this.canvas.width !== bw || this.canvas.height !== bh) {
      this.canvas.width = bw;
      this.canvas.height = bh;
    }
    this.gl.viewport(0, 0, bw, bh);
    this.gl.uniform2f(this.u.uRes, bw, bh);
  }

  bind() {
    let resizeTimer;
    window.addEventListener('resize', () => {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(() => this.resize(), 120);
    });

    // пауза вне экрана и в фоновой вкладке
    if ('IntersectionObserver' in window) {
      new IntersectionObserver((entries) => {
        this.visible = entries[0].isIntersecting;
        this.play();
      }).observe(this.box);
    }
    document.addEventListener('visibilitychange', () => this.play());

    // потеря контекста (видеодрайвер) — возвращаем картинку
    this.canvas.addEventListener('webglcontextlost', (e) => {
      e.preventDefault();
      this.dead = true;
      this.running = false;
      this.box.classList.remove('is-webgl');
      this.box.classList.add('is-fallback');
    });

    // курсор: наклон к мыши + скорость движения раскачивает поверхность
    window.addEventListener('pointermove', (e) => {
      if (e.pointerType !== 'mouse') return;
      const r = this.box.getBoundingClientRect();
      const nx = clamp((e.clientX - (r.left + r.width / 2)) / (r.width * 1.2), -1, 1);
      const ny = clamp((e.clientY - (r.top + r.height / 2)) / (r.height * 1.2), -1, 1);
      this.tiltTarget.x = nx * 0.35;
      this.tiltTarget.y = ny * 0.22;
      const t = performance.now();
      if (this.lastMove) {
        const d = Math.hypot(e.clientX - this.lastMove.x, e.clientY - this.lastMove.y);
        const speed = d / Math.max(t - this.lastMove.t, 8); // px/мс
        this.agitTarget = Math.min(1, Math.max(this.agitTarget, speed / 2.2));
      }
      this.lastMove = { x: e.clientX, y: e.clientY, t };
    }, { passive: true });

    // клик / тап по объекту
    document.addEventListener('pointerdown', (e) => {
      if (e.button > 0 || this.dead) return;
      const r = this.box.getBoundingClientRect();
      const dx = e.clientX - (r.left + r.width / 2);
      const dy = e.clientY - (r.top + r.height / 2);
      if (dx * dx + dy * dy < Math.pow(r.width * 0.36, 2)) this.tap(e.clientX, e.clientY, r);
    });
  }

  // точка касания на фигуре (в её координатах): луч камеры как в шейдере, фигура ≈ шар радиуса 1
  hitDir(cx, cy, r) {
    const aspect = r.width / r.height;
    const ux = ((cx - r.left) / r.width * 2 - 1) * aspect * 0.70;
    const uy = (1 - (cy - r.top) / r.height * 2) * 0.70;
    let ro = [0, 0, 4.2];
    let rd = norm([ux, uy, -1.6]);
    const tilt = (v) => {
      let c = Math.cos(this.tilt.y);
      let s = Math.sin(this.tilt.y);
      const y = c * v[1] - s * v[2];
      let z = s * v[1] + c * v[2];
      c = Math.cos(this.tilt.x);
      s = Math.sin(this.tilt.x);
      const x = c * v[0] - s * z;
      z = s * v[0] + c * z;
      return [x, y, z];
    };
    ro = tilt(ro);
    rd = tilt(rd);
    const b = ro[0] * rd[0] + ro[1] * rd[1] + ro[2] * rd[2];
    const h = b * b - (ro[0] * ro[0] + ro[1] * ro[1] + ro[2] * ro[2]) + 1.0;
    const t = h > 0 ? -b - Math.sqrt(h) : -b; // мимо шара — ближайшая к центру точка луча
    const p = [ro[0] + rd[0] * t, ro[1] + rd[1] * t, ro[2] + rd[2] * t];
    // мир → фигура (как map в шейдере): p.xz = M(spin) · p.xz
    const c = Math.cos(this.spin);
    const s = Math.sin(this.spin);
    return norm([c * p[0] + s * p[2], p[1], -s * p[0] + c * p[2]]);
  }

  tap(cx, cy, r) {
    const n = this.hitDir(cx, cy, r);
    const now = performance.now();
    this.taps = this.taps.filter((t) => now - t < 2600);
    this.taps.push(now);
    // «шторм»: 4 клика подряд с паузами не больше ~0.7 с
    const quick = this.taps.length >= 4 && this.taps.slice(-4).every((t, i, a) => !i || t - a[i - 1] < 700);
    const power = quick ? 1.45 : 0.8 + Math.random() * 0.35;

    // волна от точки касания — всегда; слот — свободный или самый старый
    const slot = this.hits.find((h) => h.a <= 0.001) || this.hits.reduce((m, h) => (h.age > m.age ? h : m));
    slot.n = n;
    slot.age = 0;
    slot.a = power;
    slot.f = 15 + Math.random() * 9;
    this.pulse = Math.min(this.pulse + 0.35, 1.0);
    this.ringGlow = Math.max(this.ringGlow, 0.35);

    const side = cx > r.left + r.width / 2 ? 1 : -1;
    const kick = (mood, k) => {
      if (mood === 'jelly') {
        this.squash.ax = n;
        this.squash.v += 4.0 * k;
      } else if (mood === 'twist') {
        this.twist.v += (Math.random() < 0.5 ? -1 : 1) * 7.5 * k;
      } else if (mood === 'drop') {
        // капля вылетает в сторону клика от центра (в плоскости экрана — чтобы было видно по силуэту)
        let ox = cx - (r.left + r.width / 2);
        let oy = (r.top + r.height / 2) - cy;
        if (Math.hypot(ox, oy) < r.width * 0.06) {
          const a = Math.random() * Math.PI * 2;
          ox = Math.cos(a);
          oy = Math.sin(a);
        }
        const w = norm([ox, oy, Math.hypot(ox, oy) * 0.15]);
        const c = Math.cos(this.spin);
        const s = Math.sin(this.spin);
        this.drop.dir = norm([c * w[0] + s * w[2], w[1], -s * w[0] + c * w[2]]);
        this.drop.v += 3.3 * k;
      } else if (mood === 'whirl') {
        this.spinVel += side * 2.6 * k;
        this.orbitVel += 3.2 * k;
        this.ringAxis = Math.random() < 0.5 ? RING_U : RING_V;
        this.ringTilt.v += (Math.random() < 0.5 ? -1 : 1) * 1.3 * k;
        this.ringGlow = Math.max(this.ringGlow, 1);
      }
    };
    if (quick) {
      MOODS.forEach((m) => kick(m, 0.85));
      this.orbitVel += 9.5; // шарики — лишний круг
      this.ringGlow = 1.6;
      this.pulse = 1.2;
      this.taps.length = 0;
      return;
    }
    if (!this.moods.length) {
      this.moods = MOODS.slice().sort(() => Math.random() - 0.5);
      if (this.moods[0] === this.lastMood) this.moods.push(this.moods.shift());
    }
    this.lastMood = this.moods.shift();
    kick(this.lastMood, 1);
  }

  play() {
    const on = this.visible && !document.hidden && !this.dead;
    if (on && !this.running) {
      this.running = true;
      this.last = performance.now();
      this.frames.length = 0;
      requestAnimationFrame(this.loop);
    } else if (!on) {
      this.running = false;
    }
  }

  // медленные кадры → буфер мельче (раз в 40 кадров, не ниже 0.75 css-пикселя)
  adapt(dtMs) {
    this.frames.push(dtMs);
    if (this.frames.length < 40) return;
    const avg = this.frames.reduce((a, b) => a + b, 0) / this.frames.length;
    this.frames.length = 0;
    if (avg > 22 && this.dpr * this.quality > 0.75) {
      this.quality = Math.max(0.75 / this.dpr, this.quality * 0.8);
      this.resize();
    } else if (avg < 14 && this.quality < 1 && !this.settled) {
      this.settled = true; // один шаг обратно, если запас большой (без «качелей»)
      this.quality = Math.min(1, this.quality / 0.8);
      this.resize();
    }
  }

  render(now) {
    const gl = this.gl;
    const u = this.u;
    let grow, reveal, time, spin, orbit;
    if (this.still) {
      grow = 1;
      reveal = 1.05;
      time = this.still.t;
      spin = this.still.spin;
      orbit = this.still.orbit || 0;
    } else {
      const age = (now - this.start) / 1000;
      grow = Math.max(easeOutBack(Math.min(age / 1.6, 1)), 0.001);
      reveal = easeOutExpo(clamp((age - 0.35) / 2.2, 0, 1)) * 1.05;
      time = this.time;
      spin = this.spin;
      orbit = this.orbit;
    }
    gl.uniform1f(u.uTime, time);
    gl.uniform2f(u.uSpin, Math.cos(spin), Math.sin(spin));
    gl.uniform2f(u.uTilt, this.tilt.x, this.tilt.y);
    gl.uniform1f(u.uAgit, this.agit);
    gl.uniform1f(u.uPulse, this.pulse);
    gl.uniform1f(u.uGrow, grow);
    gl.uniform1f(u.uReveal, reveal);
    // удары и «характеры»
    for (let i = 0; i < HITS; i++) {
      const h = this.hits[i];
      this.hitBuf.set([h.n[0], h.n[1], h.n[2], h.age], i * 4);
      this.hitPBuf[i * 2] = h.a;
      this.hitPBuf[i * 2 + 1] = h.f;
    }
    gl.uniform4fv(u.uHit, this.hitBuf);
    gl.uniform2fv(u.uHitP, this.hitPBuf);
    const sq = clamp(this.squash.x, -0.32, 0.32);
    gl.uniform4f(u.uSquash, this.squash.ax[0], this.squash.ax[1], this.squash.ax[2], sq);
    gl.uniform1f(u.uTwist, clamp(this.twist.x, -1.6, 1.6));
    // капля: поверхность в её направлении — снаружи внутрь до входа в фигуру, потом деление пополам
    let dr = 1.0;
    if (this.drop.x > 0.001) {
      const st = { time, grow, twist: clamp(this.twist.x, -1.6, 1.6), agit: this.agit };
      const d = this.drop.dir;
      const f = (k) => shapeF([d[0] * k, d[1] * k, d[2] * k], st);
      let hi = 2.2;
      while (hi > 0.3 && f(hi - 0.06) > 0) hi -= 0.06;
      let lo = hi - 0.06;
      for (let i = 0; i < 8; i++) {
        const m = (lo + hi) / 2;
        if (f(m) > 0) hi = m; else lo = m;
      }
      dr = hi;
    }
    gl.uniform4f(u.uDrop, this.drop.dir[0] * dr, this.drop.dir[1] * dr, this.drop.dir[2] * dr, clamp(this.drop.x, 0, 0.75));
    gl.uniform1f(u.uRingGlow, this.ringGlow);
    // орбита покачивается («вихрь»): плоскость поворачивается вокруг своей оси
    const ru = this.ringTilt.x ? rotAxis(RING_U, this.ringAxis, this.ringTilt.x) : RING_U;
    const rv = this.ringTilt.x ? rotAxis(RING_V, this.ringAxis, this.ringTilt.x) : RING_V;
    gl.uniform3fv(u.uRingU, ru);
    gl.uniform3fv(u.uRingV, rv);
    // шарики бегут по орбите навстречу друг другу; появляются вместе с орбитой
    const ballAt = (a) => {
      const c = Math.cos(a) * RING_R;
      const s = Math.sin(a) * RING_R;
      return [ru[0] * c + rv[0] * s, ru[1] * c + rv[1] * s, ru[2] * c + rv[2] * s];
    };
    const far = [0, 0, -99];
    gl.uniform3fv(u.uBall1, reveal > 0.02 ? ballAt(Math.PI + 0.25 + orbit) : far);
    gl.uniform3fv(u.uBall2, reveal > 0.6 ? ballAt(0.55 - orbit * 0.7) : far);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
  }

  loop(now) {
    if (!this.running) return;
    const dtMs = now - this.last;
    const dt = Math.min(dtMs / 16.667, 3); // в «кадрах 60fps»
    this.last = now;
    if (now - this.start > 2500) this.adapt(dtMs);

    this.agitTarget *= Math.pow(0.93, dt);
    this.agit += (this.agitTarget - this.agit) * 0.06 * dt;
    this.pulse *= Math.pow(0.955, dt);
    // удары: волны стареют, пружины «характеров» затухают
    const sec = Math.min(dtMs / 1000, 0.05);
    this.hits.forEach((h) => {
      if (h.a <= 0.001) return;
      h.age += sec;
      if (h.age > 3.2) h.a = 0;
    });
    spring(this.squash, 110, 7, sec);
    spring(this.twist, 40, 4.6, sec);
    spring(this.drop, 18, 2.3, sec); // капля: медленнее остальных — успевает вытянуться на «шейке»
    if (this.drop.x < 0) { this.drop.x = 0; this.drop.v = Math.max(this.drop.v, 0) * 0; } // капля вернулась — сливается
    spring(this.ringTilt, 30, 3.2, sec);
    this.spinVel *= Math.exp(-2.2 * sec);
    this.orbitVel *= Math.exp(-1.5 * sec);
    this.ringGlow *= Math.exp(-2.6 * sec);
    this.tilt.x += (this.tiltTarget.x - this.tilt.x) * 0.04 * dt;
    this.tilt.y += (this.tiltTarget.y - this.tilt.y) * 0.04 * dt;

    // перетекание быстрее, когда объект «волнуется»
    const k = 1 + this.agit * 2.2 + this.pulse * 2.5;
    this.time += 0.0058 * dt * k;
    this.spin += 0.0021 * dt * (1 + this.agit * 1.5) + this.spinVel * sec;
    this.orbit += 0.0035 * dt + this.orbitVel * sec;

    this.render(now);
    if (!this.ready) {
      this.ready = true;
      this.box.classList.add('is-webgl');
      this.box.classList.remove('is-fallback'); // rd-wow.js мог показать картинку, пока бандл грузился
    }
    requestAnimationFrame(this.loop);
  }
}

function init() {
  const box = document.querySelector('[data-rd-glob]');
  if (!box) return;
  // ?rd-liquid-still=t,spin,orbit,scale — один статичный кадр (снимок заглушки)
  const m = /[?&]rd-liquid-still=([\d.,-]+)/.exec(location.search);
  if (!m && window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  try {
    let still = null;
    if (m) {
      const v = m[1].split(',').map(Number);
      still = { t: v[0] || 0, spin: v[1] || 0, orbit: v[2] || 0, scale: v[3] || 1 };
    }
    new LiquidGold(box, still);
  } catch (e) {
    /* без WebGL остаётся картинка */
  }
}

if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
else init();
