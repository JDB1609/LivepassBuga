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
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <!-- Luces -->
  <div id="bg-lights" class="pointer-events-none fixed inset-0 -z-10" aria-hidden="true">
    <div class="absolute left-[12%] top-[12%] w-72 h-72 rounded-full blur-3xl opacity-25 animate-floaty"
         style="background: radial-gradient(closest-side, #6c5ce7, transparent)"></div>
    <div class="absolute right-[10%] top-[30%] w-80 h-80 rounded-full blur-3xl opacity-20 animate-floaty"
         style="animation-delay:1.2s; background: radial-gradient(closest-side, #00d1b2, transparent)"></div>
  </div>

  <main class="max-w-6xl mx-auto px-5 min-h-[calc(100vh-90px)] grid md:grid-cols-2 gap-12 items-center">
    <!-- Izquierda -->
    <div class="animate-fadeRight">
      <p class="text-aqua font-semibold mb-2">Bienvenido de nuevo</p>
      <h1 class="text-4xl md:text-5xl font-extrabold leading-tight">
        Inicia sesión en <span class="text-gradient-anim">Livepass Buga</span>
      </h1>
      <p class="text-white/70 mt-3 max-w-xl">
        Accede a tus tickets y gestiona tus eventos fácilmente.
      </p>
      <nav class="mt-6 text-white/70">
        <a href="<%= request.getContextPath() %>/Vista/PaginaPrincipal.jsp" class="hover:text-white transition">Inicio</a>
        <span class="mx-2 opacity-50">/</span><span class="opacity-90">Login</span>
      </nav>
    </div>

    <!-- Derecha: tarjeta -->
    <div class="animate-fadeUp">
      <div class="w-full max-w-md glass ring rounded-2xl p-6 mx-auto">
        <% if (loginErr != null) { %>
          <div class="mb-4 p-3 rounded-lg bg-pink-700/30 border border-pink-500/50">
            <%= loginErr %>
          </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/Control/ct_login.jsp" method="post" class="space-y-4" accept-charset="UTF-8">
          <div>
            <label class="block text-sm text-white/80 mb-1">Email</label>
            <input type="email" name="email" required
                   value="<%= fEmail != null ? fEmail : "" %>"
                   class="w-full px-4 py-3 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"
                   placeholder="tucorreo@ejemplo.com" />
          </div>

          <div>
            <label class="block text-sm text-white/80 mb-1">Contraseña</label>
            <input type="password" name="pass" required
                   class="w-full px-4 py-3 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"
                   placeholder="********" />
          </div>

          <button class="w-full btn-primary ripple" type="submit">Ingresar</button>
        </form>

        <div class="text-center text-white/70 mt-4">
          ¿No tienes cuenta?
          <a class="underline hover:text-white"
             href="<%= request.getContextPath() %>/Vista/Registro.jsp">Regístrate</a>
        </div>
      </div>
    </div>
  </main>

  <script>
    (function(){ const l=document.getElementById('bg-lights'); if(!l) return;
      addEventListener('mousemove',e=>{const x=(e.clientX/innerWidth-.5)*8,y=(e.clientY/innerHeight-.5)*8;l.style.transform=`translate(${x}px,${y}px)`;});
    })();
    (function(){ document.querySelectorAll('.ripple').forEach(b=>b.addEventListener('click',function(e){
      const r=this.getBoundingClientRect(),s=document.createElement('span'),z=Math.max(r.width,r.height);
      s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
      this.appendChild(s); setTimeout(()=>s.remove(),600);
    }));})();
  </script>
</body>
</html>
