<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="utils.Ticket" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="dao.EventDAO, utils.Event" %>

<%
  // ===== Guard: solo CLIENTE =====
  Integer _uid = (Integer) session.getAttribute("userId");
  if (_uid == null) {
    response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp");
    return;
  }
  String _role = (String) session.getAttribute("role");
  if (_role == null || !"CLIENTE".equalsIgnoreCase(_role)) {
    response.sendRedirect(request.getContextPath()+"/Vista/DashboardOrganizador.jsp");
    return;
  }
  String ctx = request.getContextPath();

  // Controlador que carga upcoming / past según usuario y búsqueda
%>
<jsp:include page="../Control/ct_mis_tickets.jsp" />

<%
  @SuppressWarnings("unchecked")
  List<Ticket> upcoming = (List<Ticket>) request.getAttribute("upcoming");
  @SuppressWarnings("unchecked")
  List<Ticket> past     = (List<Ticket>) request.getAttribute("past");

  int upCount = (upcoming!=null? upcoming.size() : 0);
  int paCount = (past!=null? past.size() : 0);

  String refOk = request.getParameter("ref");
  String ok    = request.getParameter("ok");
  String q     = request.getParameter("q") != null ? request.getParameter("q") : "";

  DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

  // DAO para traer info visual del evento (imagen, etc.)
  EventDAO evDao = new EventDAO();
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Mis tickets — Livepass Buga</title>

  <style>
    body{
      background: radial-gradient(circle at top, #161834 0, #050712 45%, #02030a 100%);
    }

    .page-shell{
      max-width: 1160px;
      margin: 0 auto;
      padding: 2.8rem 1.5rem 3.4rem;
    }
    @media(min-width:1024px){
      .page-shell{ padding-inline: 0; }
    }

    .page-header-title{
      font-size:2rem;
      line-height:1.1;
      font-weight:900;
      letter-spacing:-.04em;
    }

    .pill{
      display:inline-flex;
      align-items:center;
      gap:.35rem;
      padding:.25rem .65rem;
      border-radius:999px;
      font-weight:800;
      font-size:.72rem;
      letter-spacing:.06em;
      text-transform:uppercase;
    }
    .pill-ok{
      background:rgba(16,185,129,.18);
      color:#bbf7d0;
      border:1px solid rgba(16,185,129,.38);
    }
    .pill-used{
      background:rgba(148,163,184,.20);
      color:#e5e7eb;
      border:1px solid rgba(148,163,184,.40);
    }
    .pill-refund{
      background:rgba(244,63,94,.18);
      color:#fecdd3;
      border:1px solid rgba(244,63,94,.38);
    }
    .pill-count{
      background:rgba(15,23,42,.85);
      color:rgba(248,250,252,.92);
      border:1px solid rgba(148,163,184,.35);
    }

    .toolbar-btn{
      padding:.6rem .9rem;
      border-radius:999px;
      border:1px solid rgba(148,163,184,.40);
      background:rgba(15,23,42,.88);
      font-size:.8rem;
      font-weight:600;
      display:inline-flex;
      align-items:center;
      gap:.4rem;
      transition:border-color .16s, background .16s, transform .12s;
    }
    .toolbar-btn:hover{
      border-color:rgba(248,250,252,.85);
      background:rgba(15,23,42,.96);
      transform:translateY(-1px);
    }

    .search-shell{
      display:flex;
      flex-wrap:wrap;
      gap:.6rem;
      align-items:center;
      justify-content:flex-end;
    }
    .search-input{
      min-width:220px;
      padding:.55rem .75rem;
      border-radius:999px;
      border:1px solid rgba(148,163,184,.35);
      background:rgba(15,23,42,.88);
      color:#e5e7eb;
      font-size:.85rem;
    }
    .search-input::placeholder{
      color:rgba(148,163,184,.80);
    }

    .tag-small{
      border-radius:999px;
      padding:.22rem .55rem;
      border:1px solid rgba(148,163,184,.45);
      background:rgba(15,23,42,.92);
      font-size:.7rem;
      text-transform:uppercase;
      letter-spacing:.12em;
      color:rgba(226,232,240,.88);
    }

    .tab-btn{
      padding:.55rem .95rem;
      border-radius:999px;
      border:1px solid rgba(148,163,184,.30);
      background:rgba(15,23,42,.86);
      font-size:.8rem;
      font-weight:700;
      display:inline-flex;
      align-items:center;
      gap:.4rem;
      transition:background .15s,border-color .16s,transform .12s,color .15s;
    }
    .tab-btn span.count{
      padding:.12rem .45rem;
      border-radius:999px;
      background:rgba(15,23,42,1);
      font-size:.68rem;
      font-weight:800;
    }
    .tab-btn.active{
      background:linear-gradient(135deg,#22c55e,#14b8a6);
      border-color:rgba(34,197,94,.0);
      color:#020617;
      transform:translateY(-1px);
    }

    .tickets-grid{
      display:grid;
      gap:1.4rem;
    }
    @media(min-width:768px){
      .tickets-grid{ grid-template-columns:repeat(2,minmax(0,1fr)); }
    }
    @media(min-width:1120px){
      .tickets-grid{ grid-template-columns:repeat(3,minmax(0,1fr)); }
    }

    .ticket-card{
      position:relative;
      border-radius:18px;
      border:1px solid rgba(148,163,184,.32);
      background:radial-gradient(circle at 0 0,rgba(79,70,229,.42),transparent 55%),
                 radial-gradient(circle at 100% 120%,rgba(56,189,248,.32),transparent 55%),
                 rgba(15,23,42,.98);
      box-shadow:0 20px 55px rgba(15,23,42,.9);
      overflow:hidden;
      display:flex;
      flex-direction:column;
      height:100%;
      transition:transform .18s, box-shadow .2s, border-color .16s;
    }
    .ticket-card:hover{
      transform:translateY(-3px);
      box-shadow:0 26px 70px rgba(15,23,42,1);
      border-color:rgba(45,212,191,.8);
    }

    .ticket-media{
      position:relative;
      height:145px;
      overflow:hidden;
      background:#020617;
    }
    .ticket-media img{
      width:100%;
      height:100%;
      object-fit:cover;
      display:block;
      transform:scale(1.03);
      transition:transform .24s ease-out;
    }
    .ticket-card:hover .ticket-media img{
      transform:scale(1.07);
    }
    .ticket-media::after{
      content:"";
      position:absolute;
      inset:auto 0 0 0;
      height:46%;
      background:linear-gradient(to top,rgba(15,23,42,.96),transparent);
      pointer-events:none;
    }

    .ticket-badge-corner{
      position:absolute;
      top:10px;
      left:10px;
      z-index:2;
    }
    .ticket-date-tag{
      position:absolute;
      right:10px;
      top:10px;
      z-index:2;
      border-radius:999px;
      padding:.22rem .55rem;
      font-size:.7rem;
      background:rgba(15,23,42,.9);
      border:1px solid rgba(148,163,184,.6);
      color:rgba(226,232,240,.95);
    }

    .ticket-body{
      position:relative;
      z-index:1;
      padding:12px 14px 14px;
      display:flex;
      flex-direction:column;
      gap:.25rem;
    }
    .ticket-title{
      font-size:.95rem;
      font-weight:900;
      line-height:1.2;
      margin-bottom:.1rem;
    }
    .ticket-meta{
      font-size:.78rem;
      color:rgba(226,232,240,.88);
    }
    .ticket-meta span{
      display:block;
    }

    .ticket-extra{
      font-size:.75rem;
      color:rgba(148,163,184,.95);
      margin-top:.1rem;
    }

    .ticket-actions{
      display:flex;
      flex-wrap:wrap;
      gap:.5rem;
      margin-top:.7rem;
    }

    .btn-outline{
      padding:.5rem .9rem;
      border-radius:999px;
      border:1px solid rgba(148,163,184,.55);
      font-size:.75rem;
      font-weight:700;
      background:rgba(15,23,42,.85);
      transition:border-color .16s, background .16s, transform .1s,color .12s;
    }
    .btn-outline:hover{
      border-color:#e5e7eb;
      background:rgba(15,23,42,1);
      transform:translateY(-1px);
    }

    .empty-state{
      border-radius:20px;
      border:1px dashed rgba(148,163,184,.6);
      background:rgba(15,23,42,.9);
    }

    @keyframes fadeUp{
      from{opacity:0;transform:translateY(8px);}
      to{opacity:1;transform:translateY(0);}
    }
    .animate-fadeUp{
      animation:fadeUp .45s ease forwards;
    }
  </style>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="page-shell">
    <!-- HEADER -->
    <header class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between mb-6">
      <div>
        <div class="inline-flex items-center gap-2 mb-2">
          <span class="tag-small">Centro de entradas</span>
          <% if (upCount > 0) { %>
            <span class="pill pill-count">Activas: <%= upCount %></span>
          <% } %>
        </div>
        <h1 class="page-header-title">Mis tickets</h1>
        <p class="text-white/65 text-sm mt-1 max-w-xl">
          Aquí administras tus entradas para conciertos y eventos: muestra el QR en puerta, descarga el PDF
          o transfiere tus tickets a otra persona.
        </p>
      </div>

      <div class="search-shell">
        <a href="<%= ctx %>/Vista/HomeCliente.jsp" class="toolbar-btn">
          🏠 <span>Panel cliente</span>
        </a>
        <a href="<%= ctx %>/Vista/ExplorarEventos.jsp" class="toolbar-btn">
          🎉 <span>Explorar eventos</span>
        </a>
        <form action="../Vista/MisTickets.jsp" method="get" class="flex items-center gap-2">
          <input name="q"
                 value="<%= q %>"
                 placeholder="Buscar por nombre de evento..."
                 class="search-input" />
          <button class="btn-primary ripple text-xs px-4 py-2" type="submit">
            Buscar
          </button>
        </form>
      </div>
    </header>

    <%-- Mensaje de compra reciente --%>
    <% if ("1".equals(ok) && refOk != null) { %>
      <div class="glass ring rounded-xl p-3 mb-5 animate-fadeUp"
           style="border-color:rgba(34,197,94,.55);background:rgba(22,163,74,.16)">
        ✅ Compra registrada correctamente. Referencia de pago:
        <b><%= refOk %></b>. Ya puedes ver tus tickets en la sección <b>Próximos</b>.
      </div>
    <% } %>

    <!-- TABS -->
    <div class="flex items-center gap-3 mb-5">
      <button id="tab-up" class="tab-btn active" type="button">
        Próximos
        <span class="count"><%= upCount %></span>
      </button>
      <button id="tab-past" class="tab-btn" type="button">
        Pasados
        <span class="count"><%= paCount %></span>
      </button>
    </div>

    <!-- PANEL: PRÓXIMOS -->
    <section id="panel-up" class="tickets-grid">
      <%
        if (upCount > 0) {
          int i=0;
          for (Ticket t : upcoming) {
            String dateStr = "";
            if (t.getEventDateTime() != null) {
              dateStr = t.getEventDateTime().format(df);
            }
            // Buscar datos visuales del evento (imagen)
            Event ev = null;
            try {
              ev = evDao.findById(t.getEventId()).orElse(null);
            } catch (Exception ex) { /* ignore */ }
            String title = (ev != null && ev.getTitle()!=null) ? ev.getTitle() : t.getEventTitle();
            String venue = (ev != null && ev.getVenue()!=null) ? ev.getVenue() : t.getVenue();
            String imgSrc;
            String imgAlt;
            if (ev != null && ev.getImage()!=null && !ev.getImage().trim().isEmpty()) {
              String img = ev.getImage();
              if (img.startsWith("http://") || img.startsWith("https://")) {
                imgSrc = img;
              } else {
                imgSrc = ctx + "/" + img;
              }
              try{
                imgAlt = (ev.getImageAlt()!=null && !ev.getImageAlt().trim().isEmpty())
                         ? ev.getImageAlt()
                         : title;
              }catch(Exception e){ imgAlt = title; }
            } else {
              imgSrc = "https://images.unsplash.com/photo-1518972559570-7cc1309f3229?auto=format&fit=crop&w=1000&q=80";
              imgAlt = title;
            }

            // Fecha corta para badge (ej. 12 MAR)
            String shortDay  = "";
            String shortMon  = "";
            if (t.getEventDateTime()!=null) {
              java.time.LocalDate ld = t.getEventDateTime().toLocalDate();
              shortDay = String.valueOf(ld.getDayOfMonth());
              shortMon = ld.getMonth().toString().substring(0,3);
            }
      %>
      <article class="ticket-card animate-fadeUp" style="animation-delay:<%= (i++ * 0.06) %>s">
        <div class="ticket-media">
          <img src="<%= imgSrc %>" alt="<%= imgAlt %>" loading="lazy">
          <div class="ticket-badge-corner">
            <span class="pill pill-ok">VÁLIDO</span>
          </div>
          <% if (!shortDay.isEmpty()) { %>
          <div class="ticket-date-tag">
            <span style="font-weight:800;font-size:.78rem;"><%= shortDay %></span>
            <span style="font-size:.70rem;text-transform:uppercase;margin-left:.15rem;"><%= shortMon %></span>
          </div>
          <% } %>
        </div>
        <div class="ticket-body">
          <h3 class="ticket-title line-clamp-2"><%= title %></h3>
          <div class="ticket-meta">
            <% if (!dateStr.isEmpty()) { %>
              <span>📅 <%= dateStr %></span>
            <% } %>
            <% if (venue != null && !venue.trim().isEmpty()) { %>
              <span>📍 <%= venue %></span>
            <% } %>
          </div>
          <p class="ticket-extra">
            🎟️ Entradas: <b><%= t.getQty() %></b> · Ref. ticket: <span style="font-family:ui-monospace"><%= t.getId() %></span>
          </p>

          <div class="ticket-actions">
            <a class="btn-primary ripple text-xs"
               href="TicketQR.jsp?tid=<%= t.getId() %>">
              Ver QR
            </a>
            
          </div>
        </div>
      </article>
      <%  } // for
        } else { %>
      <div class="empty-state glass ring p-8 col-span-full text-center animate-fadeUp">
        <h3 class="text-lg font-extrabold mb-1">Sin tickets próximos</h3>
        <p class="text-white/70 text-sm max-w-md mx-auto">
          Aún no tienes entradas activas. Descubre los próximos conciertos y eventos disponibles en Livepass Buga.
        </p>
        <div class="mt-4 flex justify-center gap-3">
          <a class="btn-primary ripple px-5 py-2 text-sm"
             href="<%= ctx %>/Vista/ExplorarEventos.jsp">
            Explorar conciertos
          </a>
          <a class="btn-outline text-sm"
             href="<%= ctx %>/Vista/HomeCliente.jsp">
            Volver al panel
          </a>
        </div>
      </div>
      <% } %>
    </section>

    <!-- PANEL: PASADOS -->
    <section id="panel-past" class="tickets-grid hidden">
      <%
        if (paCount > 0) {
          int j=0;
          for (Ticket t : past) {
            String st = (t.getStatus()!=null ? t.getStatus() : "USADO");
            String pillCls;
            if ("REEMBOLSADO".equalsIgnoreCase(st))      pillCls = "pill-refund";
            else if ("VÁLIDO".equalsIgnoreCase(st)
                  || "VALIDO".equalsIgnoreCase(st))      pillCls = "pill-ok";
            else                                         pillCls = "pill-used";

            String dateStr = "";
            if (t.getEventDateTime()!=null) {
              dateStr = t.getEventDateTime().format(df);
            }

            // Info del evento para imagen
            Event ev = null;
            try {
              ev = evDao.findById(t.getEventId()).orElse(null);
            } catch(Exception ex){ /* ignore */ }

            String title = (ev != null && ev.getTitle()!=null) ? ev.getTitle() : t.getEventTitle();
            String venue = (ev != null && ev.getVenue()!=null) ? ev.getVenue() : t.getVenue();

            String imgSrc;
            String imgAlt;
            if (ev != null && ev.getImage()!=null && !ev.getImage().trim().isEmpty()) {
              String img = ev.getImage();
              if (img.startsWith("http://") || img.startsWith("https://")) {
                imgSrc = img;
              } else {
                imgSrc = ctx + "/" + img;
              }
              try{
                imgAlt = (ev.getImageAlt()!=null && !ev.getImageAlt().trim().isEmpty())
                         ? ev.getImageAlt()
                         : title;
              }catch(Exception e){ imgAlt = title; }
            } else {
              imgSrc = "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=1000&q=80";
              imgAlt = title;
            }

            // badge fecha mini
            String shortDay  = "";
            String shortMon  = "";
            if (t.getEventDateTime()!=null) {
              java.time.LocalDate ld = t.getEventDateTime().toLocalDate();
              shortDay = String.valueOf(ld.getDayOfMonth());
              shortMon = ld.getMonth().toString().substring(0,3);
            }
      %>
      <article class="ticket-card animate-fadeUp" style="animation-delay:<%= (j++ * 0.06) %>s">
        <div class="ticket-media">
          <img src="<%= imgSrc %>" alt="<%= imgAlt %>" loading="lazy">
          <div class="ticket-badge-corner">
            <span class="pill <%= pillCls %>"><%= st %></span>
          </div>
          <% if (!shortDay.isEmpty()) { %>
          <div class="ticket-date-tag">
            <span style="font-weight:800;font-size:.78rem;"><%= shortDay %></span>
            <span style="font-size:.70rem;text-transform:uppercase;margin-left:.15rem;"><%= shortMon %></span>
          </div>
          <% } %>
        </div>
        <div class="ticket-body">
          <h3 class="ticket-title line-clamp-2"><%= title %></h3>
          <div class="ticket-meta">
            <% if (!dateStr.isEmpty()) { %>
              <span>📅 <%= dateStr %></span>
            <% } %>
            <% if (venue != null && !venue.trim().isEmpty()) { %>
              <span>📍 <%= venue %></span>
            <% } %>
          </div>
          <p class="ticket-extra">
            🎟️ Entradas: <b><%= t.getQty() %></b> · Ref. ticket: <span style="font-family:ui-monospace"><%= t.getId() %></span>
          </p>

          <div class="ticket-actions">
            <span class="btn-outline text-xs cursor-not-allowed opacity-70">
              Ver QR
            </span>
            <a class="btn-outline text-xs"
               href="../Control/ct_ticket_pdf.jsp?tid=<%= t.getId() %>">
              Descargar PDF
            </a>
          </div>
        </div>
      </article>
      <% } // for
        } else { %>
      <div class="empty-state glass ring p-8 col-span-full text-center animate-fadeUp">
        <h3 class="text-lg font-extrabold mb-1">Aún no tienes eventos pasados</h3>
        <p class="text-white/70 text-sm max-w-md mx-auto">
          Cuando asistas a tus conciertos y se marquen como usados, aparecerán aquí para que puedas descargar soportes o historial.
        </p>
      </div>
      <% } %>
    </section>
  </main>

  <script>
    // Tabs
    (function(){
      const upBtn  = document.getElementById('tab-up');
      const paBtn  = document.getElementById('tab-past');
      const upSec  = document.getElementById('panel-up');
      const paSec  = document.getElementById('panel-past');

      function select(which){
        const isUp = (which === 'up');
        upSec.classList.toggle('hidden', !isUp);
        paSec.classList.toggle('hidden',  isUp);
        upBtn.classList.toggle('active',  isUp);
        paBtn.classList.toggle('active', !isUp);
      }

      upBtn && upBtn.addEventListener('click', ()=>select('up'));
      paBtn && paBtn.addEventListener('click', ()=>select('past'));
    })();

    // Ripple
    (function(){
      document.querySelectorAll('.ripple').forEach(function(btn){
        btn.addEventListener('click', function(e){
          const r = this.getBoundingClientRect();
          const s = document.createElement('span');
          const z = Math.max(r.width, r.height);
          s.style.width  = z + 'px';
          s.style.height = z + 'px';
          s.style.left   = (e.clientX - r.left - z/2) + 'px';
          s.style.top    = (e.clientY - r.top  - z/2) + 'px';
          this.appendChild(s);
          setTimeout(()=>s.remove(), 600);
        });
      });
    })();
  </script>
</body>
</html>
