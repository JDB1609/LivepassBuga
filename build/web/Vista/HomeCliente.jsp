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
    /* ===== Tarjetas generales / botones ===== */
    .cta{background:linear-gradient(180deg,rgba(255,255,255,.06),rgba(255,255,255,.04));border-radius:18px;padding:18px;border:1px solid rgba(255,255,255,.10);box-shadow:0 10px 40px rgba(0,0,0,.45);transition:transform .15s, box-shadow .22s}
    .cta:hover{transform:translateY(-2px);box-shadow:0 16px 50px rgba(0,0,0,.5)}
    .btn-ghost{border-radius:12px;padding:10px 14px;font-weight:700;border:1px solid rgba(255,255,255,.14);background:rgba(255,255,255,.04);transition:border-color .2s, transform .12s}
    .btn-ghost:hover{transform:translateY(-1px);border-color:rgba(255,255,255,.3)}
    .ev{transition:transform .15s, box-shadow .2s}.ev:hover{transform:translateY(-2px);box-shadow:0 16px 50px rgba(0,0,0,.5)}
    /* ===== KPIs ===== */
    .kpi{border:1px solid rgba(255,255,255,.10);background:rgba(255,255,255,.04);border-radius:16px;padding:16px}
    .kpi .n{font-size:1.75rem;font-weight:900;letter-spacing:-.02em}
    /* ====== HELP & PQRS Polished ====== */
    .panel{border:1px solid rgba(255,255,255,.12);background:linear-gradient(180deg,rgba(255,255,255,.05),rgba(255,255,255,.03));border-radius:18px;overflow:hidden}
    .panel-head{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:18px;border-bottom:1px solid rgba(255,255,255,.10)}
    .panel-title{font-weight:900;font-size:1.15rem;letter-spacing:-.01em}
    .panel-sub{color:rgba(255,255,255,.65);font-size:.9rem}
    .chip{display:inline-flex;align-items:center;gap:.45rem;padding:.35rem .7rem;border-radius:999px;border:1px solid rgba(255,255,255,.14);background:rgba(255,255,255,.06);font-weight:700;font-size:.8rem}
    /* Contacts */
    .contact{display:flex;gap:12px;align-items:center;padding:14px;border:1px solid rgba(255,255,255,.12);border-radius:14px;background:rgba(255,255,255,.05);transition:transform .12s, border-color .2s}
    .contact:hover{transform:translateY(-2px);border-color:rgba(255,255,255,.22)}
    .contact .ico{width:42px;height:42px;border-radius:12px;display:grid;place-items:center;background:rgba(108,92,231,.22);box-shadow:inset 0 0 0 1px rgba(255,255,255,.08)}
    /* Steps */
    .steps-v{position:relative;border-left:1px dashed rgba(255,255,255,.18);padding-left:14px}
    .steps-v .dot{position:absolute;left:-8px;top:6px;width:12px;height:12px;border-radius:999px;background:rgba(0,209,178,.6);box-shadow:0 0 0 3px rgba(0,209,178,.12)}
    /* FAQ */
    .faq details{border:1px solid rgba(255,255,255,.12);border-radius:14px;background:rgba(255,255,255,.05);overflow:hidden}
    .faq summary{cursor:pointer;font-weight:800;padding:12px 14px}
    .faq .ans{padding:12px 14px;color:rgba(255,255,255,.78);border-top:1px solid rgba(255,255,255,.08)}
    details[open] summary{background:rgba(255,255,255,.06)}
    /* Form */
    .field label{display:block;margin-bottom:6px;color:rgba(255,255,255,.8);font-size:.92rem}
    .inputx,.textareax,.selectx,.filex{width:100%;padding:.9rem 1rem;border-radius:12px;background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.14);color:#fff;outline:none;transition:border-color .16s, box-shadow .16s}
    .inputx:focus,.textareax:focus,.selectx:focus,.filex:focus{border-color:rgba(0,209,178,.6);box-shadow:0 0 0 3px rgba(0,209,178,.16) inset}
    .textareax{min-height:140px;resize:vertical}
    .btn-cta{position:relative}
    .btn-cta::after{content:"";position:absolute;inset:auto -10px -10px -10px;height:36px;filter:blur(18px);background:radial-gradient(closest-side,rgba(108,92,231,.35),transparent 70%);opacity:.55;pointer-events:none}
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
        <div class="flex items-center gap-3"><div class="w-10 h-10 grid place-items-center rounded-lg bg-primary/25">🎉</div>
          <div><div class="font-extrabold">Próximos eventos</div><div class="text-white/70 text-sm">Recomendados para ti</div></div>
        </div>
      </a>
      <a class="cta block" href="<%= request.getContextPath() %>/Vista/MisTickets.jsp">
        <div class="flex items-center gap-3"><div class="w-10 h-10 grid place-items-center rounded-lg bg-primary/25">🎫</div>
          <div><div class="font-extrabold">Mis tickets</div><div class="text-white/70 text-sm">Descarga o transfiere</div></div>
        </div>
      </a>
      <a class="cta block" href="<%= request.getContextPath() %>/Vista/HistorialCompras.jsp">
        <div class="flex items-center gap-3"><div class="w-10 h-10 grid place-items-center rounded-lg bg-primary/25">📜</div>
          <div><div class="font-extrabold">Historial</div><div class="text-white/70 text-sm">Compras pasadas</div></div>
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

    <!-- ===== Centro de ayuda + PQRS ===== -->
    <section class="grid xl:grid-cols-2 gap-6">
      <!-- Centro de ayuda -->
      <div class="panel">
        <div class="panel-head">
          <div>
            <div class="panel-title">Centro de ayuda</div>
            <div class="panel-sub">Guías rápidas y soporte</div>
          </div>
          <div class="hidden md:flex gap-2">
            <a href="<%= request.getContextPath() %>/Vista/MisTickets.jsp" class="chip">Ver mis tickets</a>
            <a href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp" class="chip">Explorar</a>
          </div>
        </div>

        <div class="p-6 grid md:grid-cols-2 gap-5">
          <!-- Contactos -->
          <div class="space-y-3">
            <div class="contact"><div class="ico">💬</div><div><div class="font-extrabold">Chat de soporte</div><div class="text-white/60 text-sm">Tiempo de respuesta &lt; 2h</div></div></div>
            <div class="contact"><div class="ico">📧</div><div><div class="font-extrabold">Email</div><div class="text-white/60 text-sm">soporte@livepassbuga.com</div></div></div>
            <div class="contact"><div class="ico">📞</div><div><div class="font-extrabold">Línea prioritaria</div><div class="text-white/60 text-sm">L–V 8:00–18:00</div></div></div>
          </div>

          <!-- Pasos + actividad -->
          <div class="space-y-4">
            <div class="contact" style="display:block">
              <div class="font-extrabold mb-2">¿Problema con una compra?</div>
              <div class="steps-v space-y-3">
                <div class="relative pl-2"><span class="dot"></span> Abre <b>Mis tickets</b> y verifica compra/ref.</div>
                <div class="relative pl-2"><span class="dot"></span> Revisa correo de confirmación (SPAM/Promociones).</div>
                <div class="relative pl-2"><span class="dot"></span> Si continúa, envía una <b>PQRS</b> con referencia y detalle.</div>
              </div>
            </div>

            <% if (recent != null && !recent.isEmpty()) { %>
              <div class="contact" style="display:block">
                <div class="font-extrabold mb-2">Actividad reciente</div>
                <ul class="space-y-1 text-white/75">
                  <% for (String item : recent) { %><li>• <%= item %></li><% } %>
                </ul>
              </div>
            <% } %>
          </div>
        </div>

        <div class="p-6 pt-0">
          <div class="faq grid md:grid-cols-3 gap-4">
            <details><summary>No llegó el correo</summary><div class="ans">Busca en SPAM/Promociones. Valídalo también en <b>Mis tickets</b>.</div></details>
            <details><summary>Reembolsos</summary><div class="ans">Dependen de la política del organizador. Envíanos una <b>PQRS</b>.</div></details>
            <details><summary>Transferencias</summary><div class="ans">Se hacen desde <b>Mis tickets → Transferir</b>.</div></details>
          </div>
        </div>
      </div>

      <!-- PQRS -->
      <div class="panel">
        <div class="panel-head">
          <div>
            <div class="panel-title">Crear PQRS</div>
            <div class="panel-sub">Respuesta promedio &lt; 24h</div>
          </div>
          <div class="hidden md:flex gap-2">
            <span class="chip">Ref de pago ayuda</span>
            <span class="chip">Adjunta evidencia</span>
          </div>
        </div>

        <form action="<%= request.getContextPath() %>/Control/ct_pqrs.jsp"
              method="post" enctype="multipart/form-data"
              class="p-6 grid md:grid-cols-2 gap-4" id="pqrsForm" novalidate>
          <input type="hidden" name="userId" value="<%= uid %>">

          <div class="field">
            <label>Tipo</label>
            <select name="type" class="selectx" required>
              <option value="">— Seleccionar —</option>
              <option value="PETICION">Petición</option>
              <option value="QUEJA">Queja</option>
              <option value="RECLAMO">Reclamo</option>
              <option value="SUGERENCIA">Sugerencia</option>
            </select>
          </div>

          <div class="field">
            <label>Referencia de pago (opcional)</label>
            <input class="inputx" name="payment_ref" placeholder="Ej: SIM-12345-678">
          </div>

          <div class="field md:col-span-2">
            <label>Asunto</label>
            <input class="inputx" name="subject" required placeholder="Breve resumen del caso">
          </div>

          <div class="field md:col-span-2">
            <label>Mensaje</label>
            <textarea class="textareax" name="message" required placeholder="Describe tu solicitud con el mayor detalle posible"></textarea>
          </div>

          <div class="field">
            <label>Adjunto (opcional)</label>
            <input type="file" class="filex" name="attachment" accept=".pdf,.jpg,.jpeg,.png">
          </div>

          <div class="md:col-span-2 flex items-center justify-between gap-3">
            <label class="inline-flex items-center gap-2 text-sm text-white/80">
              <input type="checkbox" name="notify" class="accent-current" checked>
              Notificar por correo el estado de mi PQRS
            </label>
            <button class="btn-primary btn-cta ripple px-5 py-3 rounded-xl" type="submit">Enviar PQRS</button>
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
    // Validación mínima PQRS
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
