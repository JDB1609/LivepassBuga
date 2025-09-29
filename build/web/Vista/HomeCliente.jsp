<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, java.time.format.DateTimeFormatter" %>
<%@ page import="dao.EventDAO, utils.Event" %>

<%
  // --- Sesión básica
  Integer uid  = (Integer) session.getAttribute("userId");
  String  name = (String)  session.getAttribute("name");
  String  role = (String)  session.getAttribute("role");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }
%>

<%-- KPIs y actividad reciente --%>
<jsp:include page="../Control/ct_home_cliente.jsp" />

<%
  // --- Recomendados (preview)
  List<Event> recs = new EventDAO().listFeatured(3);
  DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

  // --- KPIs del include (con fallback)
  Object _kTot = request.getAttribute("kpi_total");
  Object _kUp  = request.getAttribute("kpi_upcoming");
  Object _kRef = request.getAttribute("kpi_refunded");
  String kTot = (_kTot!=null? String.valueOf(_kTot) : "–");
  String kUp  = (_kUp !=null? String.valueOf(_kUp)  : "–");
  String kRef = (_kRef!=null? String.valueOf(_kRef) : "–");

  @SuppressWarnings("unchecked")
  List<String> recent = (List<String>) request.getAttribute("recent_activity");
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Mi panel</title>
  <style>
    /* Tarjetas y micro-interacciones */
    .cta{
      background: linear-gradient(180deg, rgba(255,255,255,.06), rgba(255,255,255,.04));
      border-radius: 18px; padding: 18px;
      box-shadow: 0 10px 40px rgba(0,0,0,.45);
      transition: transform .15s ease, box-shadow .22s ease, background .22s ease;
      border:1px solid rgba(255,255,255,.10);
    }
    .cta:hover{ transform: translateY(-2px); box-shadow: 0 16px 50px rgba(0,0,0,.5); }
    .btn-ghost{
      border-radius: 12px; padding: 10px 14px; font-weight: 700;
      border:1px solid rgba(255,255,255,.14);
      background: rgba(255,255,255,.04);
      transition: border-color .2s, transform .12s, box-shadow .22s, background .2s;
    }
    .btn-ghost:hover{ transform: translateY(-1px); border-color: rgba(255,255,255,.3); }
    .ev{ transition: transform .15s ease, box-shadow .2s ease; }
    .ev:hover{ transform: translateY(-2px); box-shadow: 0 16px 50px rgba(0,0,0,.5); }
    /* KPIs */
    .kpi{border:1px solid rgba(255,255,255,.10); background:rgba(255,255,255,.04); border-radius:16px; padding:16px}
    .kpi .n{font-size:1.75rem; font-weight:900; letter-spacing:-.02em}
    /* Inputs (PQRS) */
    .input, .textarea, .select{
      width:100%; padding:.85rem 1rem; border-radius:12px; background:transparent;
      border:1px solid rgba(255,255,255,.15); color:#fff; outline:none; appearance:none;
      transition:border-color .15s, box-shadow .15s;
    }
    .input:focus, .textarea:focus, .select:focus{ border-color:rgba(0,209,178,.6); box-shadow:0 0 0 3px rgba(0,209,178,.16) inset }
  </style>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-6xl mx-auto px-5 py-10">
    <!-- Header / acciones -->
    <section class="mb-8">
      <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 class="text-3xl md:text-4xl font-extrabold">
            Hola, <%= (name!=null? name : "usuario") %> <span aria-hidden="true">👋</span>
          </h1>
          <p class="text-white/70 mt-1">Aquí tienes un resumen y accesos rápidos a tus eventos, tickets y ayuda.</p>
        </div>
        <div class="flex flex-wrap gap-2">
          <a class="btn-primary ripple" href="<%= request.getContextPath() %>/Vista/PaginaPrincipal.jsp">Ir a inicio</a>
          <a class="btn-ghost ripple" href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">Explorar eventos</a>
          <a class="btn-ghost ripple" href="<%= request.getContextPath() %>/Vista/MisTickets.jsp">Mis tickets</a>
          <% if ("ORGANIZADOR".equalsIgnoreCase(String.valueOf(role))) { %>
            <a class="btn-ghost ripple" href="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp">Panel organizador</a>
          <% } %>
        </div>
      </div>
    </section>

    <!-- KPIs -->
    <section class="grid sm:grid-cols-3 gap-4 mb-8">
      <div class="kpi"><div class="text-white/70 text-sm">Tickets totales</div><div class="n"><%= kTot %></div></div>
      <div class="kpi"><div class="text-white/70 text-sm">Próximos</div><div class="n text-aqua"><%= kUp %></div></div>
      <div class="kpi"><div class="text-white/70 text-sm">Reembolsados</div><div class="n"><%= kRef %></div></div>
    </section>

    <!-- Quick cards -->
    <section class="grid md:grid-cols-3 gap-4 mb-10">
      <a class="cta block" href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 grid place-items-center rounded-lg bg-primary/25">🎉</div>
          <div>
            <div class="font-extrabold">Próximos eventos</div>
            <div class="text-white/70 text-sm">Recomendados para ti</div>
          </div>
        </div>
      </a>
      <a class="cta block" href="<%= request.getContextPath() %>/Vista/MisTickets.jsp">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 grid place-items-center rounded-lg bg-primary/25">🎫</div>
          <div>
            <div class="font-extrabold">Mis tickets</div>
            <div class="text-white/70 text-sm">Descarga o transfiere</div>
          </div>
        </div>
      </a>
      <a class="cta block" href="<%= request.getContextPath() %>/Vista/HistorialCompras.jsp">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 grid place-items-center rounded-lg bg-primary/25">📜</div>
          <div>
            <div class="font-extrabold">Historial</div>
            <div class="text-white/70 text-sm">Compras pasadas</div>
          </div>
        </div>
      </a>
    </section>

    <!-- Recomendados -->
    <section class="mb-12">
      <div class="flex items-end justify-between mb-3">
        <div>
          <h2 class="text-2xl font-bold">Recomendados para ti</h2>
          <p class="text-white/60">Próximamente</p>
        </div>
        <a class="text-white/70 hover:text-white transition font-semibold"
           href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">Ver todos →</a>
      </div>

      <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
        <%
          if (recs != null && !recs.isEmpty()) {
            int i = 0;
            for (Event ev : recs) {
              String dateStr = (ev.getDateTime()!=null) ? ev.getDateTime().format(df) : ev.getDate();
              String buyUrl  = (session.getAttribute("userId") == null)
                               ? request.getContextPath() + "/Vista/Login.jsp"
                               : request.getContextPath() + "/Vista/Checkout.jsp?eventId=" + ev.getId() + "&qty=1";
        %>
        <article class="ev glass ring rounded-2xl p-5 animate-fadeUp" style="animation-delay:<%= (i++ * 0.06) %>s">
          <div class="flex items-center justify-between mb-2">
            <span class="px-2.5 py-1 rounded-full text-xs font-bold bg-primary/20 text-white">★ Destacado</span>
          </div>
          <h3 class="font-bold text-lg line-clamp-2"><%= ev.getTitle() %></h3>
          <p class="text-white/70">📅 <%= dateStr %> • 📍 <%= ev.getVenue()!=null?ev.getVenue():"" %></p>
          <p class="mt-2 text-xl font-extrabold"><%= ev.getPriceFormatted() %></p>
          <div class="mt-4 flex gap-2">
            <a class="btn-primary ripple" href="<%= buyUrl %>">Comprar</a>
            <a class="btn-ghost ripple" href="<%= request.getContextPath() %>/Vista/EventoDetalle.jsp?id=<%= ev.getId() %>">Ver detalles</a>
          </div>
        </article>
        <%
            } // for
          } else {
        %>
        <div class="col-span-full glass ring rounded-2xl p-8 text-center text-white/70">
          No hay eventos recomendados por ahora.
        </div>
        <% } %>
      </div>
    </section>

    <!-- Centro de ayuda + PQRS (rediseño) -->
    <section class="grid xl:grid-cols-2 gap-6">
      <!-- Ayuda -->
      <div class="glass ring rounded-2xl p-0 overflow-hidden">
        <div class="px-6 py-5 border-b border-white/10 flex items-center justify-between">
          <div>
            <h3 class="text-xl font-extrabold">Centro de ayuda</h3>
            <p class="text-white/60 text-sm">Guías rápidas y soporte</p>
          </div>
          <div class="flex gap-2">
            <a href="<%= request.getContextPath() %>/Vista/MisTickets.jsp" class="btn-ghost">Ver mis tickets</a>
            <a href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp" class="btn-ghost">Explorar</a>
          </div>
        </div>

        <div class="p-6 grid md:grid-cols-2 gap-5">
          <div class="space-y-4">
            <div class="cta"><div class="flex items-center gap-3">
              <div class="w-10 h-10 grid place-items-center rounded-lg bg-primary/25">💬</div>
              <div><div class="font-bold">Chat de soporte</div><div class="text-white/60 text-sm">Tiempo de respuesta &lt; 2h</div></div>
            </div></div>
            <div class="cta"><div class="flex items-center gap-3">
              <div class="w-10 h-10 grid place-items-center rounded-lg bg-primary/25">📧</div>
              <div><div class="font-bold">Email</div><div class="text-white/60 text-sm">soporte@livepassbuga.com</div></div>
            </div></div>
            <div class="cta"><div class="flex items-center gap-3">
              <div class="w-10 h-10 grid place-items-center rounded-lg bg-primary/25">📞</div>
              <div><div class="font-bold">Línea prioritaria</div><div class="text-white/60 text-sm">L–V 8:00–18:00</div></div>
            </div></div>
          </div>

          <div class="cta">
            <div class="font-bold mb-3">¿Problema con una compra?</div>
            <ol class="relative border-l border-white/15 pl-4 space-y-4 text-white/80">
              <li><div class="absolute -left-[9px] top-1 w-4 h-4 rounded-full bg-primary/60"></div>
                  Abre <b>Mis tickets</b> y verifica tu compra / referencia.</li>
              <li><div class="absolute -left-[9px] top-1 w-4 h-4 rounded-full bg-primary/60"></div>
                  Revisa el correo de confirmación (SPAM/Promociones).</li>
              <li><div class="absolute -left-[9px] top-1 w-4 h-4 rounded-full bg-primary/60"></div>
                  Si sigue el problema, envía una <b>PQRS</b> con la referencia y detalle.</li>
            </ol>

            <% if (recent != null && !recent.isEmpty()) { %>
              <div class="h-px bg-white/10 my-4"></div>
              <div class="font-bold mb-2">Actividad reciente</div>
              <ul class="space-y-1 text-white/70">
                <% for (String item : recent) { %><li>• <%= item %></li><% } %>
              </ul>
            <% } %>
          </div>
        </div>

        <div class="px-6 pb-6">
          <div class="grid md:grid-cols-3 gap-4">
            <details class="cta"><summary class="cursor-pointer font-bold">No llegó el correo</summary>
              <div class="text-white/70 mt-2">Busca en SPAM/Promociones. Valídalo también en <b>Mis tickets</b>.</div>
            </details>
            <details class="cta"><summary class="cursor-pointer font-bold">Reembolsos</summary>
              <div class="text-white/70 mt-2">Dependen de la política del organizador. Envíanos una <b>PQRS</b>.</div>
            </details>
            <details class="cta"><summary class="cursor-pointer font-bold">Transferencias</summary>
              <div class="text-white/70 mt-2">Se hacen desde <b>Mis tickets → Transferir</b>.</div>
            </details>
          </div>
        </div>
      </div>

      <!-- PQRS -->
      <div class="glass ring rounded-2xl p-0 overflow-hidden">
        <div class="px-6 py-5 border-b border-white/10 flex items-center justify-between">
          <div>
            <h3 class="text-xl font-extrabold">Crear PQRS</h3>
            <p class="text-white/60 text-sm">Respuesta promedio &lt; 24h</p>
          </div>
          <div class="hidden md:flex items-center gap-3 text-white/60 text-sm">
            <span class="px-2 py-1 rounded-lg border border-white/15">Ref de pago ayuda</span>
            <span class="px-2 py-1 rounded-lg border border-white/15">Adjunta evidencia</span>
          </div>
        </div>

        <form action="<%= request.getContextPath() %>/Control/ct_pqrs.jsp" method="post" class="p-6 grid md:grid-cols-2 gap-4" id="pqrsForm" novalidate>
          <input type="hidden" name="userId" value="<%= uid %>">

          <div>
            <label class="block text-sm text-white/80 mb-1">Tipo</label>
            <select name="type" class="select" required>
              <option value="">— Seleccionar —</option>
              <option value="PETICION">Petición</option>
              <option value="QUEJA">Queja</option>
              <option value="RECLAMO">Reclamo</option>
              <option value="SUGERENCIA">Sugerencia</option>
            </select>
          </div>

          <div>
            <label class="block text-sm text-white/80 mb-1">Referencia de pago (opcional)</label>
            <input class="input" name="payment_ref" placeholder="Ej: SIM-12345-678">
          </div>

          <div class="md:col-span-2">
            <label class="block text-sm text-white/80 mb-1">Asunto</label>
            <input class="input" name="subject" required placeholder="Breve resumen del caso">
          </div>

          <div class="md:col-span-2">
            <label class="block text-sm text-white/80 mb-1">Mensaje</label>
            <textarea class="textarea" name="message" rows="5" required placeholder="Describe tu solicitud con el mayor detalle posible"></textarea>
            <p class="text-white/60 text-xs mt-2">Al enviar, aceptas ser contactado por nuestro equipo para resolver tu caso.</p>
          </div>

          <div class="md:col-span-2 flex items-center justify-between gap-3">
            <label class="inline-flex items-center gap-2 text-sm text-white/80">
              <input type="checkbox" name="notify" class="accent-current" checked>
              Notificar por correo el estado de mi PQRS
            </label>
            <button class="btn-primary ripple" type="submit">Enviar PQRS</button>
          </div>
        </form>
      </div>
    </section>

    <!-- Preferencias + Seguridad -->
    <section class="grid lg:grid-cols-2 gap-6 mt-8">
      <div class="glass ring rounded-2xl p-6">
        <h3 class="text-xl font-extrabold mb-2">Preferencias rápidas</h3>
        <div class="space-y-3 text-white/80">
          <label class="flex items-center justify-between gap-3"><span>Recordatorios del evento</span><input type="checkbox" class="accent-current" checked></label>
          <label class="flex items-center justify-between gap-3"><span>Alertas de cambios del organizador</span><input type="checkbox" class="accent-current" checked></label>
          <label class="flex items-center justify-between gap-3"><span>Promociones y novedades</span><input type="checkbox" class="accent-current"></label>
        </div>
      </div>
      <div class="glass ring rounded-2xl p-6">
        <h3 class="text-xl font-extrabold mb-2">Seguridad de tus tickets</h3>
        <ul class="list-disc pl-5 text-white/80 space-y-2">
          <li>No compartas capturas del QR en redes.</li>
          <li>Transfiere tickets desde “Mis tickets” si no vas a asistir.</li>
          <li>Verifica siempre que compras desde <b>Livepass Buga</b>.</li>
        </ul>
      </div>
    </section>
  </main>

  <script>
    // Validación mínima del PQRS
    (function(){
      const f = document.getElementById('pqrsForm');
      if (!f) return;
      f.addEventListener('submit', function(e){
        const ok = f.type.value && f.subject.value.trim() && f.message.value.trim();
        if (!ok){ e.preventDefault(); alert('Completa Tipo, Asunto y Mensaje.'); }
      });
    })();

    // Ripple
    (function(){ document.querySelectorAll('.ripple').forEach(b=>b.addEventListener('click',function(e){
      const r=this.getBoundingClientRect(),s=document.createElement('span'),z=Math.max(r.width,r.height);
      s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
      this.appendChild(s); setTimeout(()=>s.remove(),600);
    }));})();
  </script>
</body>
</html>
