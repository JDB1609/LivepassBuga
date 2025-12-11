<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.Map" %>
<%
  Map<String,String> errors = (Map<String,String>) request.getAttribute("errors");
  String nombre   = (String) request.getAttribute("f_nombre");
  String email    = (String) request.getAttribute("f_email");
  String tel      = (String) request.getAttribute("f_tel");
  String ok       = (String) request.getAttribute("signup_ok");
  String rolePrev = (String) request.getAttribute("f_role");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Registro — Livepass Buga</title>

  <!-- ICONOS MATERIAL -->
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

  <style>
    body { background: #050816; }

    /* Luces */
    .lp-lights::before,
    .lp-lights::after {
      content: "";
      position: absolute;
      filter: blur(45px);
      border-radius: 999px;
      opacity: .35;
      pointer-events: none;
    }
    .lp-lights::before {
      width: 300px; height: 300px;
      left: 10%; top: 12%;
      background: radial-gradient(circle, #6366f1, transparent 65%);
    }
    .lp-lights::after {
      width: 320px; height: 320px;
      right: 8%; bottom: 10%;
      background: radial-gradient(circle, #22d3ee, transparent 65%);
    }

    @keyframes fadeUp {
      from { opacity: 0; transform: translateY(20px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    .fade { animation: fadeUp .7s ease-out; }

    /* Tarjeta */
    .reg-frame {
      padding: 1px;
      border-radius: 22px;
      background: linear-gradient(135deg, rgba(84,105,213,.55), rgba(0,224,198,.55));
      box-shadow: 0 20px 45px rgba(0,0,0,.65);
    }
    .reg-card {
      background: rgba(10,15,28,.85);
      backdrop-filter: blur(22px) saturate(180%);
      border-radius: 22px;
      border: 1px solid rgba(255,255,255,0.06);
      padding: 28px 30px;
      box-shadow:
        inset 0 1px 0 rgba(255,255,255,.15),
        0 20px 35px rgba(15,23,42,.9);
    }

    /* Inputs */
    .reg-input {
      background: rgba(15,23,42,.92);
      border: 1px solid rgba(148,163,184,.4);
      border-radius: 14px;
      transition: .25s;
    }
    .reg-input:hover {
      border-color: rgba(0,224,198,.6);
    }
    .reg-input:focus {
      border-color: #6366f1;
      box-shadow: 0 0 0 1px #6366f1;
      outline: none;
      background: rgba(15,23,42,1);
    }

    /* Select */
    .reg-select {
      appearance: none;
      background: rgba(15,23,42,.92);
      border: 1px solid rgba(148,163,184,.4);
      border-radius: 14px;
      padding: 12px 40px 12px 40px;
      transition: .25s;
      width: 100%;
    }
    .reg-select:hover {
      border-color: rgba(0,224,198,.6);
    }

    /* Botón */
    .btn-primary {
      background: linear-gradient(135deg,#6D4AFF,#8E7DFF);
      border-radius: 14px;
      padding: .9rem 0;
      font-weight: 700;
      box-shadow: 0 14px 30px rgba(109,74,255,.40);
      transition: .25s;
    }
    .btn-primary:hover {
      transform: translateY(-2px);
      background: linear-gradient(135deg,#7C5FFF,#A094FF);
    }

    .reg-icon {
      position: absolute;
      left: 14px;
      top: 50%;
      transform: translateY(-50%);
      font-size: 20px;
      color: #9ca3af;
    }

    .reg-field { position: relative; }

    .badge-dot {
      width: 10px; height: 10px;
      border-radius: 999px;
      background: #22c55e;
      animation: pulse 1.8s infinite;
    }

    @keyframes pulse {
      0% { transform: scale(.9); opacity: .7; }
      50% { transform: scale(1.3); opacity: 1; }
      100% { transform: scale(.9); opacity: .7; }
    }

    /* Tarjetas de features izquierda */
    .feature-card {
      border-radius: 18px;
      background: rgba(15,23,42,.9);
      border: 1px solid rgba(148,163,184,.35);
      padding: .9rem .95rem;
    }

    .feature-icon {
      width: 34px;
      height: 34px;
      border-radius: 999px;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    /* Stats pills */
    .stat-pill {
      border-radius: 999px;
      border: 1px solid rgba(148,163,184,.45);
      background: rgba(15,23,42,.85);
      padding: .45rem .85rem;
      min-width: 140px;
    }

  </style>
</head>

<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <div class="lp-lights fixed inset-0 -z-10"></div>

  <main class="max-w-6xl mx-auto px-6 min-h-[calc(100vh-80px)] grid md:grid-cols-2 gap-12 items-center fade">

    <!-- IZQUIERDA -->
    <section class="space-y-7">

      <!-- Badge superior -->
      <div class="inline-flex items-center gap-2 bg-white/5 border border-white/10 px-3 py-1.5 rounded-full">
        <div class="badge-dot"></div>
        <span class="uppercase tracking-widest text-[11px] text-white/70">
          Registro de cuenta
        </span>
      </div>

      <!-- Título + subtítulo -->
      <div>
        <h1 class="text-4xl md:text-5xl font-extrabold leading-tight">
          Crea tu cuenta<br>
          <span class="text-gradient-anim">Livepass Buga</span>
        </h1>
        <p class="text-white/70 max-w-lg mt-3 text-sm sm:text-base">
          Compra tickets, gestiona tus eventos y valida accesos con nuestra plataforma profesional
          diseñada para asistentes y organizadores.
        </p>
      </div>

      <!-- Sub badge secundario -->
      <div class="inline-flex items-center gap-2 bg-emerald-500/10 border border-emerald-400/40 px-3 py-1.5 rounded-full text-[11px] text-emerald-100">
        <span class="material-icons text-[16px] text-emerald-300">verified</span>
        <span>Pagos seguros, códigos QR únicos y control de acceso en tiempo real</span>
      </div>

      <!-- Feature cards -->
      <div class="grid sm:grid-cols-2 gap-4 text-sm text-white/85">
        <div class="feature-card flex gap-3">
          <div class="feature-icon bg-indigo-500/15 border border-indigo-300/50">
            <span class="material-icons text-[18px] text-indigo-200">qr_code_scanner</span>
          </div>
          <div class="space-y-1">
            <p class="font-semibold text-[13px]">Validación con código QR</p>
            <p class="text-[11px] text-white/60">
              Cada ticket genera un código único que puedes escanear en la entrada del evento.
            </p>
          </div>
        </div>

        <div class="feature-card flex gap-3">
          <div class="feature-icon bg-cyan-500/15 border border-cyan-300/50">
            <span class="material-icons text-[18px] text-cyan-200">event</span>
          </div>
          <div class="space-y-1">
            <p class="font-semibold text-[13px]">Panel para organizadores</p>
            <p class="text-[11px] text-white/60">
              Crea eventos, controla cupos y revisa tus ventas desde un solo lugar.
            </p>
          </div>
        </div>
      </div>

      <!-- Stats pills -->
      <div class="flex flex-wrap gap-3 pt-1">
        <div class="stat-pill flex items-center gap-2 text-[11px]">
          <span class="material-icons text-[16px] text-emerald-300">groups</span>
          <span><span class="font-semibold">+200</span> asistentes activos</span>
        </div>
        <div class="stat-pill flex items-center gap-2 text-[11px]">
          <span class="material-icons text-[16px] text-sky-300">bolt</span>
          <span>Confirmación de compra <span class="font-semibold">al instante</span></span>
        </div>
        <div class="stat-pill flex items-center gap-2 text-[11px]">
          <span class="material-icons text-[16px] text-violet-300">insights</span>
          <span>Reportes listos para tus eventos</span>
        </div>
      </div>

      <!-- Breadcrumb -->
      <nav class="text-white/70 text-sm pt-1">
        <a href="PaginaPrincipal.jsp" class="hover:text-white">Inicio</a>
        <span class="mx-2 opacity-40">/</span>
        <span class="opacity-95">Registro</span>
      </nav>
    </section>

    <!-- DERECHA -->
    <section class="reg-frame fade max-w-md mx-auto js-tilt">
      <div class="reg-card">

        <!-- Mensaje OK -->
        <% if ("1".equals(ok)) { %>
          <div class="mb-4 p-3 rounded-lg bg-emerald-600/20 border border-emerald-400/40">
            <span class="material-icons text-emerald-300 mr-1 align-middle">check_circle</span>
            Registro exitoso. <a class="underline" href="Login.jsp">Inicia sesión</a>.
          </div>
        <% } %>

        <!-- FORM -->
        <form action="<%= request.getContextPath() %>/Control/ct_registro.jsp" method="post" class="space-y-4">

          <!-- Nombre -->
          <div>
            <label class="block text-sm mb-1">Nombre completo</label>
            <div class="reg-field">
              <span class="material-icons reg-icon">person</span>
              <input name="nombre" class="reg-input w-full pl-12 pr-4 py-3"
                     value="<%= nombre!=null?nombre:"" %>"
                     required placeholder="Ej: Daniela Gómez"/>
            </div>
            <% if (errors!=null && errors.get("nombre")!=null){ %>
              <div class="text-pink-300 text-sm mt-1"><%= errors.get("nombre") %></div>
            <% } %>
          </div>

          <!-- Email -->
          <div>
            <label class="block text-sm mb-1">Email</label>
            <div class="reg-field">
              <span class="material-icons reg-icon">alternate_email</span>
              <input type="email" name="email" class="reg-input w-full pl-12 pr-4 py-3"
                     value="<%= email!=null?email:"" %>"
                     required placeholder="tucorreo@ejemplo.com"/>
            </div>
            <% if (errors!=null && errors.get("email")!=null){ %>
              <div class="text-pink-300 text-sm mt-1"><%= errors.get("email") %></div>
            <% } %>
          </div>

          <!-- Tel -->
          <div>
            <label class="block text-sm mb-1">Teléfono (opcional)</label>
            <div class="reg-field">
              <span class="material-icons reg-icon">phone</span>
              <input name="telefono" class="reg-input w-full pl-12 pr-4 py-3"
                     value="<%= tel!=null?tel:"" %>"
                     placeholder="+57 300 000 0000"/>
            </div>
          </div>

          <!-- Tipo de cuenta -->
          <div>
            <label class="block text-sm mb-1">Tipo de cuenta</label>
            <div class="reg-field">
              <span class="material-icons reg-icon">how_to_reg</span>
              <select name="role" class="reg-select">
                <option value="CLIENTE" <%= "ORGANIZADOR".equals(rolePrev) ? "" : "selected" %>>Cliente</option>
                <option value="ORGANIZADOR" <%= "ORGANIZADOR".equals(rolePrev) ? "selected" : "" %>>Organizador</option>
              </select>
            </div>
            <% if (errors!=null && errors.get("role")!=null){ %>
              <div class="text-pink-300 text-sm mt-1"><%= errors.get("role") %></div>
            <% } %>
          </div>

          <!-- Passwords -->
          <div class="grid sm:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm mb-1">Contraseña</label>
              <div class="reg-field">
                <span class="material-icons reg-icon">lock</span>
                <input type="password" name="pass"
                       class="reg-input w-full pl-12 pr-4 py-3"
                       required placeholder="Mínimo 8 caracteres"/>
              </div>
              <% if (errors!=null && errors.get("pass")!=null){ %>
                <div class="text-pink-300 text-sm mt-1"><%= errors.get("pass") %></div>
              <% } %>
            </div>

            <div>
              <label class="block text-sm mb-1">Confirmar contraseña</label>
              <div class="reg-field">
                <span class="material-icons reg-icon">check_circle</span>
                <input type="password" name="pass2"
                       class="reg-input w-full pl-12 pr-4 py-3"
                       required placeholder="Repite la contraseña"/>
              </div>
              <% if (errors!=null && errors.get("pass2")!=null){ %>
                <div class="text-pink-300 text-sm mt-1"><%= errors.get("pass2") %></div>
              <% } %>
            </div>
          </div>

          <!-- GLOBAL ERROR -->
          <% if (errors!=null && errors.get("global")!=null){ %>
            <div class="p-3 rounded-lg bg-pink-600/20 border border-pink-400/40 text-sm">
              <%= errors.get("global") %>
            </div>
          <% } %>

          <!-- BOTÓN -->
          <button class="w-full btn-primary ripple" type="submit">Crear cuenta</button>
        </form>

        <p class="text-center text-sm text-white/70 mt-4">
          ¿Ya tienes cuenta?
          <a href="Login.jsp" class="underline hover:text-white">Inicia sesión</a>
        </p>

      </div>
    </section>

  </main>

  <!-- JS: Parallax, Tilt y Ripple -->
  <script>
    // Parallax luces
    (function(){ const l=document.querySelector('.lp-lights');
      if(!l) return;
      window.addEventListener('mousemove', e=>{
        const x=(e.clientX/window.innerWidth-.5)*10;
        const y=(e.clientY/window.innerHeight-.5)*10;
        l.style.transform=`translate(${x}px,${y}px)`;
      });
    })();

    // Tilt card
    (function(){
      const card=document.querySelector('.js-tilt');
      if(!card) return;
      const d=20;
      card.addEventListener('mousemove',e=>{
        const r=card.getBoundingClientRect();
        const cx=e.clientX-r.left, cy=e.clientY-r.top;
        const rx=((cy-r.height/2)/d)*-1;
        const ry=((cx-r.width/2)/d);
        card.style.transform=`perspective(900px) rotateX(${rx}deg) rotateY(${ry}deg)`;
      });
      card.addEventListener('mouseleave',()=>card.style.transform='perspective(900px)');
    })();

    // Ripple
    (function(){
      document.querySelectorAll('.ripple').forEach(b=>{
        b.addEventListener('click',e=>{
          const r=b.getBoundingClientRect();
          const s=document.createElement('span');
          const z=Math.max(r.width,r.height);
          s.style.width=s.style.height=z+'px';
          s.style.position='absolute';
          s.style.left=(e.clientX-r.left-z/2)+'px';
          s.style.top =(e.clientY-r.top -z/2)+'px';
          s.style.background='rgba(255,255,255,.3)';
          s.style.borderRadius='999px';
          s.style.opacity='0.8';
          s.style.transform='scale(0)';
          s.style.transition='transform .45s ease, opacity .45s ease';
          b.style.position='relative';
          b.appendChild(s);
          requestAnimationFrame(()=>{
            s.style.transform='scale(1.8)';
            s.style.opacity='0';
          });
          setTimeout(()=>s.remove(),500);
        });
      });
    })();
  </script>
</body>
</html>
