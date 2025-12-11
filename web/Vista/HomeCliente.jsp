<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, java.time.format.DateTimeFormatter" %>
<%@ page import="dao.EventDAO, utils.Event" %>

<%
  // --- Sesión básica
  Integer uid  = (Integer) session.getAttribute("userId");
  String  name = (String)  session.getAttribute("name");
  String  role = (String)  session.getAttribute("role");
  if (uid == null) {
      response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp");
      return;
  }
%>

<%-- KPIs y actividad reciente (controlador CT) --%>
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
  <title>Mi panel | LivePass Buga</title>

  <style>
    /* ===== Fondo general / layout ===== */
    body{
      background: radial-gradient(circle at top, #171a33 0, #050712 45%, #02030a 100%);
    }

    .page-shell{
      max-width: 1160px;
      margin: 0 auto;
      padding: 2.3rem 1.5rem 3rem;
    }
    @media(min-width:1024px){
      .page-shell{ padding-inline: 0; }
    }

    /* ===== Layout superior (hero + KPIs) ===== */
    .top-grid{
      display:grid;
      gap:1.5rem;
    }
    @media(min-width:900px){
      .top-grid{
        grid-template-columns: minmax(0,1.7fr) minmax(0,.95fr);
        align-items:stretch;
      }
    }

    .card{
      border-radius:22px;
      border:1px solid rgba(255,255,255,.12);
      background:radial-gradient(circle at top left,#6657ff3d 0,#0a0c16 45%,#050714 100%);
      box-shadow:0 24px 80px rgba(0,0,0,.78);
      position:relative;
      overflow:hidden;
    }

    .card::before{
      content:"";
      position:absolute;
      inset:-40%;
      background:
        radial-gradient(circle at 0% 0%,rgba(124,92,255,.35),transparent 52%),
        radial-gradient(circle at 100% 100%,rgba(0,209,178,.35),transparent 52%);
      opacity:.35;
      pointer-events:none;
    }

    .card-inner{
      position:relative;
      z-index:1;
      padding:20px 20px 18px;
    }

    /* ===== Hero cliente ===== */
    .hero-title{
      font-size:1.85rem;
      line-height:1.1;
      font-weight:900;
      letter-spacing:-.03em;
    }
    @media(min-width:768px){
      .hero-title{ font-size:2.15rem; }
    }
    .hero-sub{
      color:rgba(255,255,255,.76);
      font-size:.95rem;
      max-width:30rem;
    }
    .hero-tag{
      display:inline-flex;
      align-items:center;
      gap:.45rem;
      padding:.3rem .8rem;
      border-radius:999px;
      font-size:.78rem;
      border:1px solid rgba(255,255,255,.25);
      background:rgba(0,0,0,.45);
      color:rgba(255,255,255,.88);
      margin-bottom:.5rem;
    }
    .hero-tag-bullet{
      width:8px;height:8px;border-radius:999px;
      background:#00d1b2;
      box-shadow:0 0 0 4px rgba(0,209,178,.4);
    }

    .hero-actions{
      display:flex;
      flex-wrap:wrap;
      gap:.55rem;
      margin-top:1rem;
    }

    /* Buscador */
    .search-bar{
      margin-top:1rem;
      border-radius:999px;
      padding:.35rem .4rem;
      background:rgba(4,5,14,.85);
      border:1px solid rgba(255,255,255,.16);
      display:flex;
      align-items:center;
      gap:.4rem;
    }
    .search-icon{
      font-size:1.2rem;
      opacity:.7;
    }
    .search-input{
      flex:1;
      border:none;
      outline:none;
      background:transparent;
      color:#fff;
      font-size:.9rem;
      padding:.25rem .1rem;
    }
    .search-input::placeholder{
      color:rgba(255,255,255,.55);
    }
    .search-btn{
      border-radius:999px;
      padding:.4rem .9rem;
      font-size:.8rem;
      border:none;
      cursor:pointer;
    }

    /* ===== KPIs lado derecho ===== */
    .kpi-stack{
      height:100%;
      display:flex;
      flex-direction:column;
      gap:.55rem;
    }
    .kpi-card{
      flex:1;
      border-radius:18px;
      padding:12px 14px 11px;
      border:1px solid rgba(255,255,255,.13);
      background:linear-gradient(160deg,rgba(10,12,26,.9),rgba(8,9,20,.98));
      box-shadow:0 14px 40px rgba(0,0,0,.75);
      position:relative;
      overflow:hidden;
    }
    .kpi-card::after{
      content:"";
      position:absolute;
      inset:-20%;
      background:radial-gradient(circle at 120% -10%,rgba(0,209,178,.45),transparent 60%);
      opacity:.32;
      pointer-events:none;
    }
    .kpi-label{
      font-size:.74rem;
      text-transform:uppercase;
      letter-spacing:.14em;
      color:rgba(255,255,255,.6);
    }
    .kpi-value{
      font-size:1.7rem;
      font-weight:900;
      letter-spacing:-.03em;
      margin-top:.2rem;
    }
    .kpi-foot{
      font-size:.78rem;
      color:rgba(255,255,255,.72);
      margin-top:.15rem;
    }
    .kpi-pill{
      position:absolute;
      top:10px;right:12px;
      border-radius:999px;
      padding:.18rem .55rem;
      font-size:.7rem;
      background:rgba(255,255,255,.09);
      color:rgba(255,255,255,.78);
    }

    /* ===== Botones neutrales ===== */
    .btn-ghost{
      border-radius:999px;
      padding:8px 13px;
      font-weight:700;
      border:1px solid rgba(255,255,255,.18);
      background:rgba(255,255,255,.06);
      transition:border-color .18s, transform .12s, background .18s;
      font-size:.82rem;
    }
    .btn-ghost:hover{
      transform:translateY(-1px);
      border-color:rgba(0,209,178,.7);
      background:rgba(255,255,255,.08);
    }

    /* ===== Acciones rápidas ===== */
    .quick-actions{
      margin-top:1.9rem;
      display:grid;
      gap:.9rem;
    }
    @media(min-width:860px){
      .quick-actions{
        grid-template-columns:repeat(4,minmax(0,1fr));
      }
    }
    .quick-action{
      border-radius:16px;
      padding:11px 12px;
      border:1px solid rgba(255,255,255,.12);
      background:linear-gradient(160deg,rgba(9,11,24,.96),rgba(4,5,14,.98));
      display:flex;
      gap:10px;
      align-items:flex-start;
      cursor:pointer;
      transition:transform .15s, box-shadow .2s, border-color .18s;
    }
    .quick-action:hover{
      transform:translateY(-2px);
      box-shadow:0 16px 45px rgba(0,0,0,.75);
      border-color:rgba(0,209,178,.7);
    }
    .qa-icon{
      width:28px;height:28px;border-radius:10px;
      display:grid;place-items:center;
      background:rgba(115,102,255,.2);
      font-size:1.1rem;
    }
    .qa-title{
      font-size:.86rem;font-weight:800;
    }
    .qa-sub{
      font-size:.76rem;color:rgba(255,255,255,.7);
    }

    /* ===== Recomendados ===== */
    .section-head{
      margin-top:2.4rem;
      margin-bottom:.9rem;
      display:flex;
      align-items:flex-end;
      justify-content:space-between;
      gap:1rem;
    }
    .section-head h2{
      font-size:1.2rem;
      font-weight:800;
    }
    .section-sub{
      font-size:.8rem;color:rgba(255,255,255,.68);
    }

    .events-grid{
      display:grid;
      gap:1.1rem;
    }
    @media(min-width:768px){
      .events-grid{ grid-template-columns:repeat(3,minmax(0,1fr)); }
    }

    /* ===== Tarjetas de eventos refinadas ===== */
    .event-card{
      border-radius:16px;
      border:1px solid rgba(255,255,255,.06);
      background:linear-gradient(150deg,rgba(15,18,32,.96),rgba(7,9,21,.98));
      box-shadow:0 12px 30px rgba(0,0,0,.55);
      overflow:hidden;
      display:flex;
      flex-direction:column;
      transition:transform .18s, box-shadow .22s, border-color .18s;
      height:auto;
    }
    .event-card:hover{
      transform:translateY(-2px);
      box-shadow:0 18px 55px rgba(0,0,0,.7);
      border-color:rgba(0,209,178,.45);
    }

    .event-image{
      position:relative;
      overflow:hidden;
      height:145px;
      background:#070814;
    }
    .event-image img{
      width:100%;
      height:145px;
      object-fit:cover;
      display:block;
      transform:scale(1.03);
      transition:transform .22s ease;
    }
    .event-card:hover .event-image img{
      transform:scale(1.06);
    }
    .event-image::after{
      content:"";
      position:absolute;
      inset:auto 0 0 0;
      height:38%;
      background:linear-gradient(to top,rgba(5,7,18,.88),transparent);
      pointer-events:none;
    }

    .event-body{
      padding:12px 14px 13px;
      display:flex;
      flex-direction:column;
      gap:.32rem;
    }

    .event-top{
      display:flex;
      align-items:center;
      justify-content:space-between;
      margin-bottom:.15rem;
    }
    .pill-destacado{
      padding:.15rem .5rem;
      font-size:.63rem;
      border-radius:999px;
      background:rgba(132,96,255,.28);
      text-transform:uppercase;
      letter-spacing:.12em;
    }
    .event-id{
      font-size:.68rem;
      color:rgba(255,255,255,.55);
    }

    .event-title{
      font-size:.92rem;
      font-weight:800;
      line-height:1.2;
      margin-bottom:.2rem;
    }
    .event-meta{
      font-size:.74rem;
      color:rgba(255,255,255,.7);
    }
    .event-price{
      font-size:1.05rem;
      font-weight:900;
      color:#00ff9a;
      margin-top:.2rem;
    }

    .event-actions{
      margin-top:.55rem;
      display:flex;
      gap:.4rem;
    }
    .event-actions a{
      font-size:.74rem !important;
      padding:.45rem .8rem !important;
      border-radius:10px !important;
    }

    /* ===== Bloque inferior (tickets / ayuda) ===== */
    .bottom-grid{
      margin-top:2.4rem;
      display:grid;
      gap:1.4rem;
    }
    @media(min-width:960px){
      .bottom-grid{
        grid-template-columns: minmax(0,1.1fr) minmax(0,.95fr);
      }
    }

    .panel{
      border-radius:20px;
      border:1px solid rgba(255,255,255,.12);
      background:linear-gradient(160deg,rgba(12,14,30,.96),rgba(4,5,14,.98));
      box-shadow:0 18px 60px rgba(0,0,0,.78);
      overflow:hidden;
    }
    .panel-head{
      padding:14px 16px;
      border-bottom:1px solid rgba(255,255,255,.12);
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:.6rem;
    }
    .panel-title{
      font-size:1rem;
      font-weight:800;
    }
    .panel-sub{
      font-size:.8rem;
      color:rgba(255,255,255,.68);
    }
    .panel-body{
      padding:14px 16px 15px;
    }

    .activity-list{
      font-size:.8rem;
      color:rgba(255,255,255,.8);
      display:flex;
      flex-direction:column;
      gap:.25rem;
      margin-top:.45rem;
    }
    .activity-empty{
      font-size:.78rem;
      color:rgba(255,255,255,.6);
      margin-top:.4rem;
    }

    .tips-list{
      margin-top:.8rem;
      font-size:.78rem;
      color:rgba(255,255,255,.78);
      display:flex;
      flex-direction:column;
      gap:.35rem;
    }

    /* PQRS mini form */
    .field label{
      display:block;
      margin-bottom:4px;
      font-size:.78rem;
      color:rgba(255,255,255,.8);
    }
    .inputx,
    .selectx,
    .textareax{
      width:100%;
      padding:.7rem .8rem;
      border-radius:12px;
      border:1px solid rgba(255,255,255,.13);
      background:rgba(255,255,255,.03);
      color:#fff;
      font-size:.8rem;
      outline:none;
      transition:border-color .16s, box-shadow .16s, background .14s;
    }
    .inputx:focus,
    .selectx:focus,
    .textareax:focus{
      border-color:rgba(0,209,178,.75);
      box-shadow:0 0 0 1px rgba(0,209,178,.65);
      background:rgba(255,255,255,.05);
    }
    .textareax{
      resize:vertical;
      min-height:80px;
    }

    .pqrs-footer{
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:.6rem;
      margin-top:.7rem;
    }
    .pqrs-footer label{
      font-size:.75rem;
      color:rgba(255,255,255,.78);
    }

    .faq-chips{
      display:flex;
      flex-wrap:wrap;
      gap:.4rem;
      margin-top:.7rem;
      font-size:.75rem;
    }
    .faq-chip{
      border-radius:999px;
      padding:.25rem .6rem;
      border:1px solid rgba(255,255,255,.18);
      background:rgba(255,255,255,.05);
      cursor:default;
      color:rgba(255,255,255,.82);
    }

    /* Animaciones */
    @keyframes fadeUp{
      from{opacity:0;transform:translateY(10px);}
      to{opacity:1;transform:translateY(0);}
    }
    .animate-fadeUp{
      animation:fadeUp .45s ease forwards;
    }

    /* Ripple simple */
    .ripple{
      position:relative;
      overflow:hidden;
    }
    .ripple span{
      position:absolute;
      border-radius:50%;
      transform:scale(0);
      animation:rippleAnim .6s linear;
      background:rgba(255,255,255,.35);
      pointer-events:none;
    }
    @keyframes rippleAnim{
      to{transform:scale(3);opacity:0;}
    }
  </style>
</head>

<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="page-shell">
    <!-- ===== TOP: HERO + KPIs ===== -->
    <section class="top-grid">
      <!-- HERO CLIENTE -->
      <div class="card animate-fadeUp">
        <div class="card-inner">
          <div class="hero-tag">
            <span class="hero-tag-bullet"></span>
            Panel de control de tu cuenta
          </div>
          <h1 class="hero-title">
            Hola, <%= (name != null ? name : "usuario") %> 👋
          </h1>
          <p class="hero-sub mt-2">
            Aquí puedes buscar eventos, revisar tus tickets, ver tu actividad
            y abrir PQRS en un solo lugar.
          </p>

          <!-- Buscador de eventos / ticket -->
          <form class="search-bar" method="get"
                action="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">
            <span class="material-icons search-icon">search</span>
            <input class="search-input"
                   type="text"
                   name="q"
                   placeholder="Buscar eventos o escribir código de ticket (ej: SIM-12345)">
            <button class="btn-primary search-btn ripple" type="submit">
              Buscar
            </button>
          </form>

          <!-- Acciones principales -->
          <div class="hero-actions">
            <a class="btn-primary ripple"
               href="<%= request.getContextPath() %>/Vista/MisTickets.jsp">
              Ver mis tickets
            </a>
            <a class="btn-ghost ripple"
               href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">
              Explorar eventos
            </a>
            <a class="btn-ghost ripple"
               href="<%= request.getContextPath() %>/Vista/HistorialCompras.jsp">
              Historial de compras
            </a>
            <% if ("ORGANIZADOR".equalsIgnoreCase(String.valueOf(role))) { %>
              <a class="btn-ghost ripple"
                 href="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp">
                Panel organizador
              </a>
            <% } %>
          </div>
        </div>
      </div>

      <!-- KPI STACK -->
      <div class="kpi-stack animate-fadeUp" style="animation-delay:.08s">
        <div class="kpi-card">
          <div class="kpi-pill">Total</div>
          <div class="kpi-label">Tickets en tu cuenta</div>
          <div class="kpi-value"><%= kTot %></div>
          <div class="kpi-foot">Entradas adquiridas con tu correo.</div>
        </div>
        <div class="kpi-card">
          <div class="kpi-pill">Próximos</div>
          <div class="kpi-label">Eventos pendientes</div>
          <div class="kpi-value text-aqua"><%= kUp %></div>
          <div class="kpi-foot">No los pierdas, revisa la fecha y lugar.</div>
        </div>
        <div class="kpi-card">
          <div class="kpi-pill">Reembolsos</div>
          <div class="kpi-label">Tickets reembolsados</div>
          <div class="kpi-value"><%= kRef %></div>
          <div class="kpi-foot">Según políticas del organizador.</div>
        </div>
      </div>
    </section>

    <!-- ===== ACCIONES RÁPIDAS ===== -->
    <section class="quick-actions">
      <a class="quick-action" href="<%= request.getContextPath() %>/Vista/MisTickets.jsp">
        <div class="qa-icon">🎫</div>
        <div>
          <div class="qa-title">Mostrar QR de entrada</div>
          <div class="qa-sub">Ten a mano tus códigos para el acceso.</div>
        </div>
      </a>

      <a class="quick-action" href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">
        <div class="qa-icon">🎉</div>
        <div>
          <div class="qa-title">Explorar nuevos eventos</div>
          <div class="qa-sub">Conciertos, festivales y más cerca de ti.</div>
        </div>
      </a>

      <a class="quick-action" href="<%= request.getContextPath() %>/Vista/HistorialCompras.jsp">
        <div class="qa-icon">📜</div>
        <div>
          <div class="qa-title">Descargar comprobantes</div>
          <div class="qa-sub">Revisa pagos anteriores y facturación.</div>
        </div>
      </a>

      <a class="quick-action" href="#pqrs-block">
        <div class="qa-icon">🛟</div>
        <div>
          <div class="qa-title">Ayuda y PQRS</div>
          <div class="qa-sub">Reporta un problema con tu compra.</div>
        </div>
      </a>
    </section>

    <!-- ===== RECOMENDADOS ===== -->
    <section>
      <div class="section-head">
        <div>
          <h2>Eventos recomendados</h2>
          <p class="section-sub">
            Basado en popularidad y fechas próximas.
          </p>
        </div>
        <a class="text-white/70 hover:text-white transition font-semibold text-xs sm:text-sm"
           href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">
          Ver todos →
        </a>
      </div>

      <div class="events-grid">
        <%
          if (recs != null && !recs.isEmpty()) {
            int i = 0;
            for (Event ev : recs) {

              String dateStr = (ev.getDateTime()!=null)
                               ? ev.getDateTime().format(df)
                               : ev.getDate();

              String img     = ev.getImage();
              String imgAlt;
              try {
                  imgAlt = (ev.getImageAlt() != null && !ev.getImageAlt().trim().isEmpty())
                           ? ev.getImageAlt()
                           : ev.getTitle();
              } catch (Exception ignore) {
                  imgAlt = ev.getTitle();
              }

              String imgSrc;
              if (img != null && !img.trim().isEmpty()) {
                if (img.startsWith("http://") || img.startsWith("https://")) {
                  imgSrc = img;
                } else {
                  imgSrc = request.getContextPath() + "/" + img;
                }
              } else {
                imgSrc = "https://images.unsplash.com/photo-1518972559570-7cc1309f3229?auto=format&fit=crop&w=900&q=80";
              }

              // URL de detalles del evento (para comprar y ver info)
              String detailUrl = request.getContextPath()
                                + "/Vista/EventoDetalle.jsp?id=" + ev.getId();
        %>
        <article class="event-card animate-fadeUp" style="animation-delay:<%= (i++ * 0.06) %>s">
          <div class="event-image">
            <img src="<%= imgSrc %>" alt="<%= imgAlt %>">
          </div>
          <div class="event-body">
            <div class="event-top">
              <span class="pill-destacado">Destacado</span>
              <span class="event-id">ID #<%= ev.getId() %></span>
            </div>
            <div class="event-title"><%= ev.getTitle() %></div>
            <div class="event-meta">
              📅 <%= dateStr %><br>
              📍 <%= ev.getVenue()!=null ? ev.getVenue() : "" %>
            </div>
            <div class="event-price"><%= ev.getPriceFormatted() %></div>
            <div class="event-actions">
              <!-- AHORA COMPRAR LLEVA A EVENTO DETALLE -->
              <a class="btn-primary ripple"
                 href="<%= detailUrl %>">
                Comprar ahora
              </a>
              <a class="btn-ghost ripple"
                 href="<%= detailUrl %>">
                Ver detalles
              </a>
            </div>
          </div>
        </article>
        <%
            } // for
          } else {
        %>
        <div class="glass ring rounded-2xl p-8 text-center text-white/70 text-sm">
          No hay eventos recomendados por ahora. Muy pronto verás aquí nuevas sugerencias para ti.
        </div>
        <% } %>
      </div>
    </section>

    <!-- ===== BLOQUE INFERIOR: TICKETS + AYUDA / PQRS ===== -->
    <section class="bottom-grid">
      <!-- Panel: tus tickets y actividad -->
      <div class="panel">
        <div class="panel-head">
          <div>
            <div class="panel-title">Tus tickets y actividad</div>
            <div class="panel-sub">Acceso rápido a tu cuenta.</div>
          </div>
          <a class="btn-ghost ripple text-xs"
             href="<%= request.getContextPath() %>/Vista/MisTickets.jsp">
            Ver todos
          </a>
        </div>
        <div class="panel-body">
          <p class="text-xs text-white/70">
            Desde <b>Mis tickets</b> puedes mostrar el QR, transferir a otra persona
            o descargar comprobantes.
          </p>

          <div class="tips-list">
            <div>• Consulta la hora y puerta de acceso antes de salir de casa.</div>
            <div>• Si no vas a asistir, usa la opción <b>Transferir ticket</b>.</div>
            <div>• Revisa que el correo de confirmación no haya llegado a SPAM.</div>
          </div>

          <hr class="border-white/10 my-3">

          <h4 class="text-xs font-semibold text-white/70">Actividad reciente</h4>
          <%
            if (recent != null && !recent.isEmpty()) {
          %>
          <ul class="activity-list">
            <% for (String item : recent) { %>
              <li>• <%= item %></li>
            <% } %>
          </ul>
          <% } else { %>
          <div class="activity-empty">
            Aún no registramos movimientos recientes. Tus próximas compras aparecerán aquí.
          </div>
          <% } %>
        </div>
      </div>

      <!-- Panel: ayuda + PQRS -->
      <div class="panel" id="pqrs-block">
        <div class="panel-head">
          <div>
            <div class="panel-title">Ayuda rápida / PQRS</div>
            <div class="panel-sub">
              Reporta problemas con pagos o acceso a eventos.
            </div>
          </div>
        </div>
        <div class="panel-body">
          <form action="<%= request.getContextPath() %>/Control/ct_pqrs.jsp"
                method="post" enctype="multipart/form-data"
                id="pqrsForm" novalidate>
            <input type="hidden" name="userId" value="<%= uid %>">

            <div class="grid gap-3">
              <div class="field">
                <label>Tipo de solicitud</label>
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
                <input class="inputx" name="payment_ref"
                       placeholder="Ej: SIM-12345-678">
              </div>

              <div class="field">
                <label>Asunto</label>
                <input class="inputx" name="subject" required
                       placeholder="Resúmen corto del caso">
              </div>

              <div class="field">
                <label>Mensaje</label>
                <textarea class="textareax" name="message" required
                          placeholder="Cuéntanos qué ocurrió, con fechas, evento y detalles."></textarea>
              </div>

              <div class="field">
                <label>Adjunto (opcional)</label>
                <input type="file" class="inputx" name="attachment"
                       accept=".pdf,.jpg,.jpeg,.png">
              </div>
            </div>

            <div class="pqrs-footer">
              <label class="inline-flex items-center gap-2">
                <input type="checkbox" name="notify" class="accent-current" checked>
                <span>Recibir notificaciones por correo.</span>
              </label>
              <button type="submit"
                      class="btn-primary ripple px-4 py-2 rounded-xl text-xs sm:text-sm">
                Enviar PQRS
              </button>
            </div>
          </form>

          <div class="faq-chips">
            <span class="faq-chip">No llegó el correo</span>
            <span class="faq-chip">Problema con el QR</span>
            <span class="faq-chip">Reembolso</span>
            <span class="faq-chip">Datos de facturación</span>
          </div>
        </div>
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
        if (!ok){
          e.preventDefault();
          alert('Completa Tipo, Asunto y Mensaje para enviar tu PQRS.');
        }
      });
    })();

    // Ripple
    (function(){
      document.querySelectorAll('.ripple').forEach(function(btn){
        btn.addEventListener('click', function(e){
          const r = this.getBoundingClientRect();
          const s = document.createElement('span');
          const z = Math.max(r.width, r.height);
          s.style.width = s.style.height = z + 'px';
          s.style.left = (e.clientX - r.left - z/2) + 'px';
          s.style.top  = (e.clientY - r.top  - z/2) + 'px';
          this.appendChild(s);
          setTimeout(function(){ s.remove(); }, 600);
        });
      });
    })();
  </script>
</body>
</html>
