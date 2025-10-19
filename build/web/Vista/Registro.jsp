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
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <!-- Luces parallax -->
  <div id="bg-lights" class="pointer-events-none fixed inset-0 -z-10" aria-hidden="true">
    <div class="absolute left-[12%] top-[12%] w-72 h-72 rounded-full blur-3xl opacity-25 animate-floaty"
         style="background: radial-gradient(closest-side, #6c5ce7, transparent)"></div>
    <div class="absolute right-[10%] top-[30%] w-80 h-80 rounded-full blur-3xl opacity-20 animate-floaty"
         style="animation-delay:1.2s; background: radial-gradient(closest-side, #00d1b2, transparent)"></div>
  </div>

  <main class="relative">
    <section class="max-w-6xl mx-auto px-5 min-h-[calc(100vh-90px)] grid md:grid-cols-2 gap-12 items-center">
      <!-- Izquierda -->
      <div class="animate-fadeRight">
        <p class="text-aqua font-semibold mb-2">Bienvenido</p>
        <h1 class="text-4xl md:text-5xl font-extrabold leading-tight">
          Crea tu cuenta en <span class="text-gradient-anim">Livepass Buga</span>
        </h1>
        <p class="text-white/70 mt-3 max-w-xl">Compra y gestiona tus tickets con validación QR.</p>
        <nav class="mt-6 text-white/70">
          <a href="PaginaPrincipal.jsp" class="hover:text-white transition">Inicio</a>
          <span class="mx-2 opacity-50">/</span><span class="opacity-90">Registro</span>
        </nav>
      </div>

      <!-- Derecha: tarjeta -->
      <div class="animate-fadeUp">
        <div class="w-full max-w-md glass ring rounded-2xl p-6 mx-auto js-tilt">
          <% if ("1".equals(ok)) { %>
            <div class="mb-4 p-3 rounded-lg bg-emerald-600/20 border border-emerald-400/40">
              ✅ Registro exitoso. <a class="underline" href="Login.jsp">Inicia sesión</a>.
            </div>
          <% } %>

          <form action="<%= request.getContextPath() %>/Control/ct_registro.jsp" method="post" class="space-y-4" autocomplete="off">
            <div>
              <label class="block text-sm text-white/80 mb-1">Nombre completo</label>
              <input name="nombre" value="<%= nombre!=null?nombre:"" %>" required
                     class="w-full px-4 py-3 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"
                     placeholder="Ej: Daniela Gómez" />
              <% if (errors!=null && errors.get("nombre")!=null){ %>
                <div class="text-pink-300 text-sm mt-1"><%= errors.get("nombre") %></div>
              <% } %>
            </div>

            <div>
              <label class="block text-sm text-white/80 mb-1">Email</label>
              <input type="email" name="email" value="<%= email!=null?email:"" %>" required
                     class="w-full px-4 py-3 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"
                     placeholder="tucorreo@ejemplo.com" />
              <% if (errors!=null && errors.get("email")!=null){ %>
                <div class="text-pink-300 text-sm mt-1"><%= errors.get("email") %></div>
              <% } %>
            </div>

            <div>
              <label class="block text-sm text-white/80 mb-1">Teléfono (opcional)</label>
              <input name="telefono" value="<%= tel!=null?tel:"" %>"
                     class="w-full px-4 py-3 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"
                     placeholder="+57 300 000 0000" />
            </div>

            <!-- Tipo de cuenta (único select que queda) -->
            <div>
              <label class="block text-sm text-white/80 mb-1">Tipo de cuenta</label>
              <select name="role" required class="ui-select w-full">
                <option value="CLIENTE" <%= "ORGANIZADOR".equals(rolePrev) ? "" : "selected" %>>Cliente</option>
                <option value="ORGANIZADOR" <%= "ORGANIZADOR".equals(rolePrev) ? "selected" : "" %>>Organizador</option>
              </select>
              <% if (errors!=null && errors.get("role")!=null){ %>
                <div class="text-pink-300 text-sm mt-1"><%= errors.get("role") %></div>
              <% } %>
            </div>

            <div class="grid sm:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm text-white/80 mb-1">Contraseña</label>
                <input type="password" name="pass" required
                       class="w-full px-4 py-3 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"
                       placeholder="Mínimo 8 caracteres" />
                <% if (errors!=null && errors.get("pass")!=null){ %>
                  <div class="text-pink-300 text-sm mt-1"><%= errors.get("pass") %></div>
                <% } %>
              </div>
              <div>
                <label class="block text-sm text-white/80 mb-1">Confirmar contraseña</label>
                <input type="password" name="pass2" required
                       class="w-full px-4 py-3 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"
                       placeholder="Repite la contraseña" />
                <% if (errors!=null && errors.get("pass2")!=null){ %>
                  <div class="text-pink-300 text-sm mt-1"><%= errors.get("pass2") %></div>
                <% } %>
              </div>
            </div>

            <button class="w-full btn-primary ripple" type="submit">Crear cuenta</button>
          </form>

          <% if (errors!=null && errors.get("global")!=null){ %>
            <div class="mt-4 p-3 rounded-lg bg-pink-600/20 border border-pink-400/40"><%= errors.get("global") %></div>
          <% } %>
        </div>
      </div>
    </section>
  </main>

  <!-- JS: parallax + tilt + ripple -->
  <script>
    (function(){ const l=document.getElementById('bg-lights'); if(!l) return;
      addEventListener('mousemove',e=>{const x=(e.clientX/innerWidth-.5)*8,y=(e.clientY/innerHeight-.5)*8;l.style.transform=`translate(${x}px,${y}px)`;});
    })();
    (function(){ const c=document.querySelector('.js-tilt'); if(!c) return; const d=20;
      c.addEventListener('mousemove',e=>{const r=c.getBoundingClientRect(),cx=e.clientX-r.left,cy=e.clientY-r.top;
        const rx=((cy-r.height/2)/d)*-1, ry=((cx-r.width/2)/d); c.style.transform=`perspective(800px) rotateX(${rx}deg) rotateY(${ry}deg)`;});
      c.addEventListener('mouseleave',()=>c.style.transform='perspective(800px) rotateX(0) rotateY(0)');
    })();
    (function(){ document.querySelectorAll('.ripple').forEach(b=>b.addEventListener('click',function(e){
      const r=this.getBoundingClientRect(),s=document.createElement('span'),z=Math.max(r.width,r.height);
      s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
      this.appendChild(s); setTimeout(()=>s.remove(),600);
    }));})();
  </script>
</body>
</html>
