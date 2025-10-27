<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String loginErr = (String) request.getAttribute("login_error");
  String fEmail   = (String) request.getAttribute("f_email");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Login Administrador — Livepass Buga</title>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <!-- Fondo con luces animadas -->
  <div id="bg-lights" class="pointer-events-none fixed inset-0 -z-10" aria-hidden="true">
    <div class="absolute left-[15%] top-[15%] w-72 h-72 rounded-full blur-3xl opacity-25 animate-floaty"
         style="background: radial-gradient(closest-side, #ff9f43, transparent)"></div>
    <div class="absolute right-[10%] top-[30%] w-80 h-80 rounded-full blur-3xl opacity-20 animate-floaty"
         style="animation-delay:1.5s; background: radial-gradient(closest-side, #1dd1a1, transparent)"></div>
  </div>

  <main class="max-w-6xl mx-auto px-5 min-h-[calc(100vh-90px)] grid md:grid-cols-2 gap-12 items-center">
    <!-- Columna izquierda -->
    <div class="animate-fadeRight">
      <p class="text-orange-400 font-semibold mb-2">Bienvenido administrador</p>
      <h1 class="text-4xl md:text-5xl font-extrabold leading-tight">
        Inicia sesión en el <span class="text-gradient-anim">Panel Administrativo</span>
      </h1>
      <p class="text-white/70 mt-3 max-w-xl">
        Gestiona eventos, usuarios y reportes del sistema Livepass Buga.
      </p>
      <nav class="mt-6 text-white/70">
        <a href="<%= request.getContextPath() %>/Vista/PaginaPrincipal.jsp" class="hover:text-white transition">Inicio</a>
        <span class="mx-2 opacity-50">/</span><span class="opacity-90">Login Administrador</span>
      </nav>
    </div>

    <!-- Columna derecha: formulario -->
    <div class="animate-fadeUp">
      <div class="w-full max-w-md glass ring rounded-2xl p-6 mx-auto">
        <% if (loginErr != null) { %>
          <div class="mb-4 p-3 rounded-lg bg-red-700/30 border border-red-500/50">
            <%= loginErr %>
          </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/Control/ct_login_admin.jsp"
              method="post" class="space-y-4" accept-charset="UTF-8">

          <div>
            <label class="block text-sm text-white/80 mb-1">Email</label>
            <input type="email" name="email" required
                   value="<%= fEmail != null ? fEmail : "" %>"
                   class="w-full px-4 py-3 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-orange-400"
                   placeholder="admin@livepass.com" />
          </div>

          <div>
            <label class="block text-sm text-white/80 mb-1">Contraseña</label>
            <input type="password" name="pass" required
                   class="w-full px-4 py-3 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-orange-400"
                   placeholder="********" />
          </div>

          <button class="w-full btn-primary ripple bg-orange-500 hover:bg-orange-600 transition"
                  type="submit">
            Ingresar
          </button>
        </form>

        <div class="text-center text-white/70 mt-4 text-sm">
          <p>Solo personal autorizado puede acceder a este panel.</p>
          <a href="<%= request.getContextPath() %>/Vista/LoginAdmin.jsp"
             class="underline hover:text-white mt-2 inline-block">Volver al login de usuarios</a>
        </div>
      </div>
    </div>
  </main>

  <!-- Scripts de animación -->
  <script>
    // Movimiento suave del fondo
    (function(){
      const l=document.getElementById('bg-lights');
      if(!l) return;
      addEventListener('mousemove',e=>{
        const x=(e.clientX/innerWidth-.5)*8, y=(e.clientY/innerHeight-.5)*8;
        l.style.transform=`translate(${x}px,${y}px)`;
      });
    })();

    // Efecto "ripple" en el botón
    (function(){
      document.querySelectorAll('.ripple').forEach(b=>b.addEventListener('click',function(e){
        const r=this.getBoundingClientRect(), s=document.createElement('span'), z=Math.max(r.width,r.height);
        s.style.width=s.style.height=z+'px';
        s.style.left=(e.clientX-r.left-z/2)+'px';
        s.style.top=(e.clientY-r.top-z/2)+'px';
        this.appendChild(s);
        setTimeout(()=>s.remove(),600);
      }));
    })();
  </script>
</body>
</html>