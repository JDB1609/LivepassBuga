<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String loginErr = (String) request.getAttribute("login_error");
  String fEmail   = (String) request.getAttribute("f_email");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Login — Livepass Buga</title>

  <!-- Iconos de Material (qr_code_scanner, key, visibility, etc.) -->
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

  <style>
    /* =============================
       ESTILOS ESPECÍFICOS LOGIN
       ============================= */

    body {
      background: #050816;
    }

    /* Luces de fondo suaves */
    .lp-login-lights::before,
    .lp-login-lights::after {
      content: "";
      position: absolute;
      border-radius: 999px;
      filter: blur(40px);
      opacity: .35;
      pointer-events: none;
    }

    .lp-login-lights::before {
      width: 260px;
      height: 260px;
      left: 8%;
      top: 12%;
      background: radial-gradient(circle, #6366f1, transparent 65%);
    }

    .lp-login-lights::after {
      width: 300px;
      height: 300px;
      right: 6%;
      bottom: 8%;
      background: radial-gradient(circle, #22d3ee, transparent 70%);
    }

    @keyframes lp-fade-up {
      from {
        opacity: 0;
        transform: translateY(12px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .lp-hero-col {
      animation: lp-fade-up .6s ease-out;
    }

    .lp-card-wrap {
      padding: 1px;
      border-radius: 22px;
      background: linear-gradient(135deg, rgba(84,105,213,.65), rgba(0,224,198,.75));
      box-shadow: 0 18px 45px rgba(0,0,0,.60);
      animation: lp-fade-up .75s ease-out;
    }

    .lp-card {
      border-radius: 22px;
      background: linear-gradient(135deg, rgba(12,16,32,.96), rgba(7,10,22,.96));
      backdrop-filter: blur(26px) saturate(140%);
      border: 1px solid rgba(255,255,255,0.06);
      box-shadow:
        inset 0 1px 0 rgba(255,255,255,.12),
        0 18px 35px rgba(15,23,42,.85);
    }

    .lp-label {
      font-size: .78rem;
      letter-spacing: .08em;
      text-transform: uppercase;
    }

    .lp-input {
      border-radius: .9rem;
      background: rgba(15,23,42,.9);
      border: 1px solid rgba(148,163,184,.4);
      transition: .2s ease;
    }

    .lp-input:hover {
      border-color: rgba(0,224,198,.55);
    }

    .lp-input:focus {
      border-color: #6366f1;
      box-shadow: 0 0 0 1px rgba(99,102,241,.9);
      background: rgba(15,23,42,.98);
      outline: none;
    }

    /* Botón principal vitaminado pero respetando .btn-primary */
    .btn-primary {
      border-radius: 14px;
      background: linear-gradient(135deg,#6D4AFF,#8E7DFF);
      box-shadow: 0 14px 30px rgba(109,74,255,.55);
      font-weight: 700;
      letter-spacing: .03em;
      padding-top: .8rem;
      padding-bottom: .8rem;
    }

    .btn-primary:hover {
      transform: translateY(-2px);
      background: linear-gradient(135deg,#7C5FFF,#A094FF);
    }

    .lp-pill {
      font-size: .7rem;
      letter-spacing: .22em;
      text-transform: uppercase;
    }

    .lp-promo-badge {
      position: relative;
      padding: .28rem .7rem .28rem .5rem;
      border-radius: 999px;
      background: rgba(15,23,42,.9);
      border: 1px solid rgba(148,163,184,.4);
    }

    .lp-promo-dot {
      width: 9px;
      height: 9px;
      border-radius: 999px;
      background: #22c55e;
      box-shadow: 0 0 12px rgba(34,197,94,.9);
    }

    .lp-login-glow {
      position: absolute;
      bottom: -34px;
      left: 50%;
      transform: translateX(-50%);
      width: 260px;
      height: 70px;
      background: radial-gradient(ellipse at center,
                                  rgba(84,105,213,.55),
                                  rgba(0,0,0,0));
      filter: blur(26px);
      z-index: -1;
    }

    @media (max-width: 767px) {
      main.lp-login-main {
        padding-top: 4.5rem;
      }
    }
  </style>
</head>

<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <!-- Capa de luces / fondo -->
  <div class="lp-login-lights fixed inset-0 -z-10"></div>

  <main class="lp-login-main max-w-6xl mx-auto px-5 lg:px-6 min-h-[calc(100vh-80px)] py-10 lg:py-16 grid lg:grid-cols-[1.05fr,0.95fr] gap-10 lg:gap-14 items-center">
    <!-- COLUMNA IZQUIERDA -->
    <section class="lp-hero-col space-y-5">
      <!-- badge superior -->
      <div class="lp-promo-badge inline-flex items-center gap-2">
        <span class="lp-promo-dot"></span>
        <span class="lp-pill text-xs text-slate-200/80">
          Plataforma para eventos en vivo
        </span>
      </div>

      <div>
        <p class="text-aqua font-semibold mb-1 text-sm">Bienvenido de nuevo</p>
        <h1 class="text-3xl sm:text-4xl lg:text-5xl font-extrabold leading-tight">
          Inicia sesión en<br>
          <span class="text-gradient-anim">Livepass Buga</span>
        </h1>
        <p class="text-white/70 mt-3 max-w-xl text-sm sm:text-base">
          Accede a tus tickets, revisa tus compras y controla la entrada a tus eventos
          con una plataforma pensada para organizadores y asistentes exigentes.
        </p>
      </div>

      <!-- mini features -->
      <div class="grid sm:grid-cols-2 gap-4 text-sm text-white/80">
        <div class="flex gap-3">
          <div class="mt-0.5 flex h-8 w-8 items-center justify-center rounded-xl bg-emerald-500/15 border border-emerald-300/40">
            <span class="material-icons text-[18px] text-emerald-300">qr_code_scanner</span>
          </div>
          <div>
            <p class="font-semibold text-sm">Check-in con código QR</p>
            <p class="text-[11px] text-white/55">
              Valida tickets desde tu móvil o lector QR y controla el aforo en tiempo real.
            </p>
          </div>
        </div>

        <div class="flex gap-3">
          <div class="mt-0.5 flex h-8 w-8 items-center justify-center rounded-xl bg-indigo-500/15 border border-indigo-300/40">
            <span class="material-icons text-[18px] text-indigo-300">confirmation_number</span>
          </div>
          <div>
            <p class="font-semibold text-sm">Todos tus tickets en un solo lugar</p>
            <p class="text-[11px] text-white/55">
              Revisa tus compras y descarta duplicados con un historial centralizado.
            </p>
          </div>
        </div>
      </div>

      <!-- breadcrumb -->
      <nav class="pt-3 text-white/60 text-sm">
        <a href="<%= request.getContextPath() %>/Vista/PaginaPrincipal.jsp"
           class="hover:text-white transition">Inicio</a>
        <span class="mx-2 opacity-50">/</span>
        <span class="opacity-90">Login</span>
      </nav>
    </section>

    <!-- COLUMNA DERECHA (solo tarjeta) -->
    <section class="relative flex items-center justify-center">
      <div class="lp-card-wrap w-full max-w-md mx-auto">
        <div class="lp-card p-6 sm:p-7 relative">
          <!-- cabecera -->
          <div class="flex items-center gap-3 mb-5">
            <div class="h-9 w-9 rounded-2xl bg-emerald-400/12 border border-emerald-300/40 flex items-center justify-center">
              <span class="material-icons text-[18px] text-emerald-300">lock</span>
            </div>
            <div>
              <p class="lp-label text-slate-100/90">Acceso seguro</p>
              <p class="text-[11px] text-slate-300/70">
                Tu sesión está protegida con conexión cifrada.
              </p>
            </div>
          </div>

          <% if (loginErr != null) { %>
            <div class="mb-4 p-3 rounded-lg bg-pink-700/30 border border-pink-500/50 text-sm">
              <%= loginErr %>
            </div>
          <% } %>

          <form action="<%= request.getContextPath() %>/Control/ct_login.jsp"
                method="post"
                class="space-y-4"
                accept-charset="UTF-8">

            <!-- EMAIL -->
            <div>
              <label class="block lp-label text-slate-100 mb-1.5">Email</label>
              <div class="relative">
                <span class="material-icons absolute left-3 top-1/2 -translate-y-1/2 text-[18px] text-slate-300/60">
                  alternate_email
                </span>
                <input
                  type="email"
                  name="email"
                  required
                  value="<%= fEmail != null ? fEmail : "" %>"
                  class="lp-input w-full pl-10 pr-4 py-3 text-sm placeholder:text-slate-400"
                  placeholder="tucorreo@ejemplo.com" />
              </div>
            </div>

            <!-- PASSWORD -->
            <div>
              <label class="block lp-label text-slate-100 mb-1.5">Contraseña</label>
              <div class="relative">
                <span class="material-icons absolute left-3 top-1/2 -translate-y-1/2 text-[18px] text-slate-300/60">
                  key
                </span>
                <input
                  id="passField"
                  type="password"
                  name="pass"
                  required
                  class="lp-input w-full pl-10 pr-10 py-3 text-sm placeholder:text-slate-400"
                  placeholder="********" />
                <button
                  type="button"
                  id="togglePass"
                  class="absolute right-3 top-1/2 -translate-y-1/2 text-[18px] text-slate-300/70 hover:text-white transition"
                  aria-label="Mostrar u ocultar contraseña">
                  <span class="material-icons" id="toggleIcon">visibility</span>
                </button>
              </div>

              <div class="mt-2 flex items-center justify-between text-[11px] text-slate-300/75">
                <label class="flex items-center gap-1.5 cursor-pointer">
                  <input type="checkbox"
                         class="w-3.5 h-3.5 rounded border-slate-500 bg-transparent">
                  <span>Mantener sesión iniciada</span>
                </label>
                <a href="#" class="hover:text-white underline decoration-dotted">
                  ¿Olvidaste tu contraseña?
                </a>
              </div>
            </div>

            <button class="w-full btn-primary ripple mt-2" type="submit">
              Ingresar
            </button>
          </form>

          <div class="text-center text-slate-200/80 mt-4 text-sm">
            ¿No tienes cuenta?
            <a class="underline hover:text-white"
               href="<%= request.getContextPath() %>/Vista/Registro.jsp">Regístrate</a>
          </div>

          <p class="mt-3 text-center text-[11px] text-slate-400/80">
            Al continuar aceptas los términos y la política de privacidad de Livepass Buga.
          </p>

          <div class="lp-login-glow"></div>
        </div>
      </div>
    </section>
  </main>

  <script>
    // Parallax suave de luces
    (function(){
      const lights = document.querySelector('.lp-login-lights');
      if(!lights) return;
      window.addEventListener('mousemove', e => {
        const x = (e.clientX / window.innerWidth  - .5) * 10;
        const y = (e.clientY / window.innerHeight - .5) * 10;
        lights.style.transform = `translate(${x}px, ${y}px)`;
      });
    })();

    // Ripple en botones .ripple
    (function(){
      document.querySelectorAll('.ripple').forEach(btn => {
        btn.addEventListener('click', function(e){
          const rect = this.getBoundingClientRect();
          const wave = document.createElement('span');
          const size = Math.max(rect.width, rect.height);
          wave.style.position = 'absolute';
          wave.style.borderRadius = '999px';
          wave.style.pointerEvents = 'none';
          wave.style.background = 'rgba(255,255,255,.22)';
          wave.style.width = wave.style.height = size + 'px';
          wave.style.left = (e.clientX - rect.left - size / 2) + 'px';
          wave.style.top  = (e.clientY - rect.top  - size / 2) + 'px';
          wave.style.opacity = '0.9';
          wave.style.transform = 'scale(0)';
          wave.style.transition = 'transform .45s ease, opacity .45s ease';
          this.style.position = 'relative';
          this.appendChild(wave);
          requestAnimationFrame(() => {
            wave.style.transform = 'scale(1.8)';
            wave.style.opacity = '0';
          });
          setTimeout(() => wave.remove(), 500);
        });
      });
    })();

    // Mostrar / ocultar contraseña
    (function(){
      const pass = document.getElementById('passField');
      const btn  = document.getElementById('togglePass');
      const icon = document.getElementById('toggleIcon');
      if(!pass || !btn || !icon) return;

      btn.addEventListener('click', () => {
        const isHidden = pass.type === 'password';
        pass.type = isHidden ? 'text' : 'password';
        icon.textContent = isHidden ? 'visibility_off' : 'visibility';
      });
    })();
  </script>
</body>
</html>
