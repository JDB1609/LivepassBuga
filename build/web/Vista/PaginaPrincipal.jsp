<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="utils.Event" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Livepass Buga — Inicio</title>
  <style>
    /* ===== Helpers globales de esta vista ===== */
    .float-wrapper{ will-change: transform; animation-duration:7s; animation-timing-function:ease-in-out; }
    .section{ padding:48px 0; }
    .pill{ display:inline-block; padding:.35rem .7rem; border-radius:999px; border:1px solid rgba(255,255,255,.12); background:rgba(255,255,255,.06); font-weight:700; font-size:.85rem }
    .card{ border:1px solid rgba(255,255,255,.08); border-radius:16px; padding:16px; background:rgba(255,255,255,.04); transition:transform .14s ease, box-shadow .24s ease, border-color .2s ease }
    .card:hover{ transform:translateY(-2px); border-color:rgba(255,255,255,.14); box-shadow:0 12px 36px rgba(0,0,0,.35) }
    .kpi{ border:1px solid rgba(255,255,255,.08); border-radius:16px; padding:16px; background:rgba(255,255,255,.04) }
    .accordion-item{ border:1px solid rgba(255,255,255,.08); border-radius:14px; overflow:hidden; background:rgba(255,255,255,.03) }
    .accordion-btn{ width:100%; text-align:left; padding:14px 16px; font-weight:700 }
    .accordion-body{ display:none; padding:0 16px 14px; color:rgba(255,255,255,.75) }
    .accordion-item.open .accordion-body{ display:block }
    .accordion-item.open .chev{ transform:rotate(180deg) }

    /* ====== Cards de eventos (alineación perfecta de botones) ====== */
    .ev-card{
      display:flex; flex-direction:column; height:100%;
      border-radius:16px; padding:20px;
      border:1px solid rgba(255,255,255,.10); background:rgba(255,255,255,.04);
      transition:transform .16s ease, box-shadow .24s ease, border-color .2s ease, background .2s ease;
    }
    .ev-card:hover{ transform:translateY(-2px); box-shadow:0 12px 36px rgba(0,0,0,.35); border-color:rgba(255,255,255,.14); background:rgba(255,255,255,.05); }

    .ev-title{ font-size:1.05rem; font-weight:800; color:#fff; margin-top:.2rem }
    .ev-meta{ margin-top:.25rem; color:rgba(255,255,255,.70); }
    .ev-meta--reserve{ min-height:42px; } /* reserva para 1–2 líneas */
    .clamp-1{ display:-webkit-box; -webkit-line-clamp:1; -webkit-box-orient:vertical; overflow:hidden; }

    .ev-price{ font-size:1.25rem; font-weight:900; margin-top:.75rem }

    .ev-actions{ margin-top:auto; display:flex; gap:.6rem; align-items:center }
    .btn{ display:inline-flex; align-items:center; justify-content:center; height:42px; padding:0 16px; border-radius:12px; font-weight:800 }
    .btn-secondary{ border:1px solid rgba(255,255,255,.15); background:transparent; }
    .btn-secondary:hover{ border-color:rgba(255,255,255,.30) }
  </style>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <!-- Luces -->
  <div id="bg-lights" class="pointer-events-none fixed inset-0 -z-10">
    <div class="absolute left-[12%] top-[12%] w-72 h-72 rounded-full blur-3xl opacity-25 animate-floaty"
         style="background: radial-gradient(closest-side, #6c5ce7, transparent)"></div>
    <div class="absolute right-[10%] top-[30%] w-80 h-80 rounded-full blur-3xl opacity-20 animate-floaty"
         style="animation-delay:1.2s; background: radial-gradient(closest-side, #00d1b2, transparent)"></div>
  </div>

  <!-- HERO -->
  <section class="relative">
    <div class="max-w-6xl mx-auto px-5 pt-12 pb-6 grid md:grid-cols-2 gap-10 items-center">
      <div class="animate-fadeRight">
        <div class="float-wrapper animate-floaty" style="animation-delay:.35s">
          <p class="text-aqua font-semibold">Plataforma moderna</p>
          <h1 class="text-3xl md:text-5xl font-extrabold leading-tight">
            Compra, gestiona y valida <span class="text-gradient-anim">tickets con QR</span>
          </h1>
          <p class="text-white/70 mt-3 max-w-xl">Experiencias sin filas, validación instantánea y seguridad total.</p>
          <div class="mt-6 flex flex-wrap gap-3">
            <a href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp" class="btn-primary ripple">Explorar eventos</a>
            <a href="<%= request.getContextPath() %>/Vista/Registro.jsp" class="px-5 py-3 rounded-xl border border-white/15 hover:border-white/30 font-bold transition">Crear cuenta</a>
          </div>
          <div class="flex flex-wrap gap-3 mt-4 text-white/70">
            <span class="px-3 py-1 rounded-full border border-white/10">🔒 Validación segura</span>
            <span class="px-3 py-1 rounded-full border border-white/10">📡 Online / Offline</span>
            <span class="px-3 py-1 rounded-full border border-white/10">📈 Reportes en vivo</span>
          </div>
        </div>
      </div>

      <div class="animate-fadeUp">
        <div class="float-wrapper animate-floaty">
          <div class="glass ring rounded-2xl p-5 relative overflow-hidden js-tilt">
            <div class="flex items-center gap-2 text-white/70 border-b border-white/10 pb-3">
              <span>📅</span><span class="font-semibold">Próximo evento</span>
            </div>
            <div class="py-4">
              <h3 class="text-xl font-bold">Sunset Sessions</h3>
              <p class="text-white/70">Parque del Río • 20/10/2025</p>
              <a class="mt-4 inline-flex btn-primary ripple" href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">Ver detalles</a>
            </div>
            <div class="absolute -bottom-20 -right-20 w-60 h-60 rounded-full bg-primary/25 blur-3xl"></div>
          </div>
        </div>
      </div>
    </div>
    <div class="h-12 border-b border-white/10"></div>
  </section>

  <!-- DESTACADOS -->
  <main class="max-w-6xl mx-auto px-5 section">
    <div class="flex items-end justify-between mb-3">
      <div>
        <h2 class="text-2xl font-extrabold tracking-tight">Eventos destacados</h2>
        <p class="text-white/60">Lo más popular esta semana</p>
      </div>
      <a href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp" class="font-semibold opacity-90 hover:opacity-100 hover:underline">
        Ver todos →
      </a>
    </div>

    <%-- Cargar datos --%>
    <jsp:include page="../Control/ct_PaginaPrincipal.jsp" />

    <%
      List<Event> featured = (List<Event>) request.getAttribute("featured");
      java.time.format.DateTimeFormatter df = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    %>

    <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
      <%
        if (featured != null && !featured.isEmpty()) {
          int i = 0, shown = 0;
          for (Event ev : featured) {
            if (shown >= 3) break; // <-- solo 3
            String title   = (ev.getTitle()!=null? ev.getTitle() : "(sin título)");
            String venue   = (ev.getVenue()!=null? ev.getVenue() : "");
            String dateStr = (ev.getDateTime()!=null) ? ev.getDateTime().format(df) : ev.getDate();
            String buyUrl  = (session.getAttribute("userId") == null)
                    ? request.getContextPath() + "/Vista/Login.jsp"
                    : request.getContextPath() + "/Vista/Checkout.jsp?eventId=" + ev.getId() + "&qty=1";
      %>
      <article class="ev-card animate-fadeUp" style="animation-delay:<%= (i++ * 0.08) %>s">
        <div class="flex items-center justify-between mb-3">
          <span class="pill">★ Destacado</span>
        </div>

        <h3 class="ev-title"><%= title %></h3>

        <p class="ev-meta ev-meta--reserve">
          <% if (dateStr != null && !dateStr.isEmpty()) { %>
            📅 <%= dateStr %>
          <% } %>
          <% if (venue != null && !venue.isEmpty()) { %>
            • <span class="clamp-1">📍 <%= venue %></span>
          <% } %>
        </p>

        <p class="ev-price"><%= ev.getPriceFormatted() %></p>

        <div class="ev-actions">
          <a class="btn btn-primary ripple" href="<%= buyUrl %>">Comprar</a>
          <a class="btn btn-secondary" href="<%= request.getContextPath() %>/Vista/EventoDetalle.jsp?id=<%= ev.getId() %>">
            Ver detalles
          </a>
        </div>
      </article>
      <%
            shown++;
          } // for
        } else {
      %>
      <div class="col-span-full glass ring rounded-2xl p-8 text-center text-white/70">
        No hay eventos publicados por ahora.
      </div>
      <% } %>
    </div>
  </main>

  <!-- CÓMO FUNCIONA -->
  <section class="section border-t border-white/10">
    <div class="max-w-6xl mx-auto px-5">
      <h3 class="text-xl font-extrabold">¿Cómo funciona?</h3>
      <p class="text-white/60 mb-5">Compra en 3 pasos, sin complicaciones.</p>
      <div class="grid md:grid-cols-3 gap-4">
        <div class="card">
          <div class="pill mb-2">1</div>
          <h4 class="font-bold">Explora eventos</h4>
          <p class="text-white/70">Filtra por ciudad, fecha o categoría. Información clara y actualizada.</p>
        </div>
        <div class="card">
          <div class="pill mb-2">2</div>
          <h4 class="font-bold">Compra segura</h4>
          <p class="text-white/70">Pago protegido, confirmación inmediata y tu QR al instante.</p>
        </div>
        <div class="card">
          <div class="pill mb-2">3</div>
          <h4 class="font-bold">Valida y disfruta</h4>
          <p class="text-white/70">Muestra tu QR en acceso. Validación incluso offline.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- CATEGORÍAS POPULARES -->
  <section class="section border-t border-white/10">
    <div class="max-w-6xl mx-auto px-5">
      <div class="flex items-end justify-between mb-3">
        <h3 class="text-xl font-extrabold">Categorías populares</h3>
        <a class="opacity-90 hover:opacity-100 hover:underline" href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">Ver todo →</a>
      </div>
      <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <a class="card" href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp?cat=musica">
          <div class="font-bold mb-1">🎵 Música</div>
          <div class="text-white/70 text-sm">Conciertos y festivales.</div>
        </a>
        <a class="card" href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp?cat=conferencias">
          <div class="font-bold mb-1">🎤 Conferencias</div>
          <div class="text-white/70 text-sm">Tech, negocios y tendencias.</div>
        </a>
        <a class="card" href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp?cat=deportes">
          <div class="font-bold mb-1">🏆 Deportes</div>
          <div class="text-white/70 text-sm">Partidos y torneos.</div>
        </a>
        <a class="card" href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp?cat=lifestyle">
          <div class="font-bold mb-1">🍷 Lifestyle</div>
          <div class="text-white/70 text-sm">Gastronomía y cultura.</div>
        </a>
      </div>
    </div>
  </section>

  <!-- MÉTRICAS -->
  <section class="section border-t border-white/10">
    <div class="max-w-6xl mx-auto px-5 grid sm:grid-cols-3 gap-4">
      <div class="kpi text-center">
        <div class="text-3xl font-extrabold">+120K</div>
        <div class="text-white/70 text-sm">Entradas validadas</div>
      </div>
      <div class="kpi text-center">
        <div class="text-3xl font-extrabold">99.95%</div>
        <div class="text-white/70 text-sm">Uptime plataforma</div>
      </div>
      <div class="kpi text-center">
        <div class="text-3xl font-extrabold">&lt;1s</div>
        <div class="text-white/70 text-sm">Validación por QR</div>
      </div>
    </div>
  </section>

  <!-- TESTIMONIOS -->
  <section class="section border-t border-white/10">
    <div class="max-w-6xl mx-auto px-5">
      <h3 class="text-xl font-extrabold mb-3">Lo que dicen los asistentes</h3>
      <div class="grid md:grid-cols-3 gap-4">
        <div class="card">
          <p class="text-white/80">“Compré desde el celular y el QR funcionó perfecto. Sin filas.”</p>
          <div class="mt-3 text-white/60 text-sm">— Laura M.</div>
        </div>
        <div class="card">
          <p class="text-white/80">“Como organizadores validamos miles de tickets muy rápido.”</p>
          <div class="mt-3 text-white/60 text-sm">— Buga Music Fest</div>
        </div>
        <div class="card">
          <p class="text-white/80">“Pude transferir mi ticket a un amigo en un clic.”</p>
          <div class="mt-3 text-white/60 text-sm">— Andrés P.</div>
        </div>
      </div>
    </div>
  </section>

  <!-- ALIADOS -->
  <section class="section border-t border-white/10">
    <div class="max-w-6xl mx-auto px-5">
      <h3 class="text-xl font-extrabold mb-4">Aliados</h3>
      <div class="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-6 gap-3 items-center">
        <div class="card text-center py-6 opacity-80">Movistar Arena</div>
        <div class="card text-center py-6 opacity-80">Plaza Mayor</div>
        <div class="card text-center py-6 opacity-80">Coliseo</div>
        <div class="card text-center py-6 opacity-80">Teatro Central</div>
        <div class="card text-center py-6 opacity-80">Live Nation</div>
        <div class="card text-center py-6 opacity-80">Buga Fest</div>
      </div>
    </div>
  </section>

  <!-- FAQ -->
  <section class="section border-t border-white/10">
    <div class="max-w-6xl mx-auto px-5">
      <h3 class="text-xl font-extrabold mb-3">Preguntas frecuentes</h3>
      <div class="space-y-3">
        <div class="accordion-item">
          <button class="accordion-btn flex items-center justify-between w-full">
            ¿Cómo recibo mis entradas? <svg class="chev" width="18" height="18" viewBox="0 0 24 24"><path fill="currentColor" d="M7 10l5 5 5-5"/></svg>
          </button>
          <div class="accordion-body">Tras el pago, enviamos el QR por correo y queda disponible en “Mis tickets”.</div>
        </div>
        <div class="accordion-item">
          <button class="accordion-btn flex items-center justify-between w-full">
            ¿Puedo entrar sin internet? <svg class="chev" width="18" height="18" viewBox="0 0 24 24"><path fill="currentColor" d="M7 10l5 5 5-5"/></svg>
          </button>
          <div class="accordion-body">Sí. Descarga tu QR; los validadores funcionan offline.</div>
        </div>
        <div class="accordion-item">
          <button class="accordion-btn flex items-center justify-between w-full">
            ¿Qué pasa si no puedo asistir? <svg class="chev" width="18" height="18" viewBox="0 0 24 24"><path fill="currentColor" d="M7 10l5 5 5-5"/></svg>
          </button>
          <div class="accordion-body">Puedes transferir el ticket o pedir reembolso si aplica la política del evento.</div>
        </div>
      </div>
    </div>
  </section>

  <!-- NEWSLETTER -->
  <section class="section border-t border-white/10">
    <div class="max-w-6xl mx-auto px-5">
      <div class="card md:flex md:items-center md:justify-between">
        <div class="mb-3 md:mb-0">
          <h4 class="font-extrabold text-lg">¿Te avisamos de nuevos eventos?</h4>
          <p class="text-white/70 text-sm">Boletín semanal con lo mejor en tu ciudad.</p>
        </div>
        <form class="flex gap-2 w-full md:w-auto" action="#" method="post" onsubmit="event.preventDefault(); alert('¡Gracias!');">
          <input type="email" required placeholder="tu@email.com"
                 class="w-full md:w-72 px-3 py-2 rounded-lg bg-transparent border border-white/15 focus:border-white/30 outline-none">
          <button class="btn-primary">Suscribirme</button>
        </form>
      </div>
    </div>
  </section>

  <!-- CTA FINAL -->
  <section class="section border-t border-white/10">
    <div class="max-w-6xl mx-auto px-5 text-center">
      <h3 class="text-2xl font-extrabold">¿Listo para tu próximo evento?</h3>
      <p class="text-white/70 mt-2">Crea tu cuenta o explora todo el calendario.</p>
      <div class="mt-5 flex items-center justify-center gap-3">
        <a class="btn-primary" href="<%= request.getContextPath() %>/Vista/Registro.jsp">Crear cuenta</a>
        <a class="px-5 py-3 rounded-xl border border-white/15 hover:border-white/30 font-bold transition"
           href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">Explorar eventos</a>
      </div>
    </div>
  </section>

  <footer class="border-t border-white/10">
    <div class="max-w-6xl mx-auto px-5 py-6 flex flex-col sm:flex-row items-center justify-between text-white/70">
      <div class="font-extrabold flex items-center gap-2">Livepass <span class="text-aqua">Buga</span></div>
      <div>© <%= java.time.Year.now() %> Livepass Buga</div>
      <div><a class="btn-primary" href="<%= request.getContextPath() %>/Vista/Login_admin.jsp">Login Adminsitrador</a></div>
    </div>
  </footer>

  <script>
    // Luces
    (function(){
      const lights = document.getElementById('bg-lights'); if(!lights) return;
      addEventListener('mousemove', e=>{
        const x=(e.clientX/innerWidth-.5)*8,y=(e.clientY/innerHeight-.5)*8;
        lights.style.transform=`translate(${x}px,${y}px)`;
      });
    })();
    // Tilt tarjeta hero
    (function(){
      const card=document.querySelector('.js-tilt'); if(!card) return; const d=20;
      card.addEventListener('mousemove',e=>{
        const r=card.getBoundingClientRect(),cx=e.clientX-r.left,cy=e.clientY-r.top;
        const rx=((cy-r.height/2)/d)*-1, ry=((cx-r.width/2)/d);
        card.style.transform=`perspective(800px) rotateX(${rx}deg) rotateY(${ry}deg)`;
      });
      card.addEventListener('mouseleave',()=>card.style.transform='perspective(800px) rotateX(0) rotateY(0)');
    })();
    // Ripple
    (function(){ document.querySelectorAll('.ripple').forEach(b=>b.addEventListener('click',function(e){
      const r=this.getBoundingClientRect(),s=document.createElement('span'),z=Math.max(r.width,r.height);
      s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
      this.appendChild(s); setTimeout(()=>s.remove(),600);
    }));})();
    // FAQ acordeón
    (function(){
      document.querySelectorAll('.accordion-item').forEach(it=>{
        const btn = it.querySelector('.accordion-btn');
        btn.addEventListener('click', ()=> it.classList.toggle('open'));
      });
    })();
  </script>
</body>
</html>
