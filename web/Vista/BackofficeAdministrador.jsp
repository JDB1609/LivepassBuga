<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, dao.EventDAO, utils.Event, dao.DashboardDAO" %>

<%
    Long uid   = (Long) session.getAttribute("adminId");
    String role  = (String) session.getAttribute("role");
    String name  = (String) session.getAttribute("adminNombre");

    if (uid == null) {
        response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp");
        return;
    }
    if (role == null || !"admin".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp");
        return;
    }

    DashboardDAO daodash = new DashboardDAO();
    int totalUsuarios       = daodash.totalUsuarios();
    int totalOrganizadores  = daodash.totalOrganizadores();
    int totalEventos        = daodash.totalEventos();
    int totalTickets        = daodash.totalTickets();
    double totalComisiones  = daodash.totalComisiones();

    EventDAO eventDAO = new EventDAO();
    int pageSize = 5;   // máximo 5 próximos eventos
    int offset   = 0;   // desde el primero

    List<Event> pendientes = eventDAO.listPendingPaged(pageSize, offset);

    String msgEvento = (String) session.getAttribute("msgEvento");
    if (msgEvento != null) {
        session.removeAttribute("msgEvento");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base.jspf" %>
    <title>Panel — Administrador | LivePassBuga</title>

    <style>
      body{
        background:#050816;
        color:white;
        font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        position:relative;
        overflow-x:hidden;
      }

      body::before{
        content:"";
        position:fixed;
        width:480px;
        height:480px;
        border-radius:999px;
        background:radial-gradient(circle at center,rgba(56,189,248,.18),transparent 70%);
        filter:blur(8px);
        opacity:.85;
        bottom:-160px;
        right:-180px;
        pointer-events:none;
        z-index:-1;
      }
      body::after{
        content:"";
        position:fixed;
        width:420px;
        height:420px;
        border-radius:999px;
        background:radial-gradient(circle at center,rgba(129,140,248,.24),transparent 70%);
        filter:blur(10px);
        opacity:.7;
        top:-160px;
        left:-140px;
        pointer-events:none;
        z-index:-1;
      }

      .lp-admin-header{
        background:rgba(5,8,22,.92);
        border-bottom:1px solid rgba(148,163,184,.3);
        backdrop-filter:blur(14px);
      }

      .lp-pill{
        font-size:.65rem;
        text-transform:uppercase;
        letter-spacing:.22em;
        padding:.2rem .75rem;
        border-radius:999px;
        border:1px solid rgba(148,163,184,.7);
        background:rgba(15,23,42,.85);
        color:#e5e7eb;
      }

      .metric{
        background:radial-gradient(circle at top left,rgba(56,189,248,.18),rgba(15,23,42,1));
        border-radius:18px;
        padding:16px 16px 14px;
        box-shadow:0 16px 45px rgba(0,0,0,.55), inset 0 1px 0 rgba(255,255,255,.03);
        border:1px solid rgba(148,163,184,.35);
        display:flex;
        flex-direction:column;
        gap:6px;
        transition:transform .15s ease, box-shadow .15s ease, border-color .15s ease;
      }
      .metric:hover{
        transform:translateY(-3px);
        box-shadow:0 22px 60px rgba(0,0,0,.8);
        border-color:rgba(56,189,248,.7);
      }
      .metric-label{
        font-size:.8rem;
        color:rgba(226,232,240,.9);
        display:flex;
        align-items:center;
        gap:.45rem;
      }
      .metric-dot{
        width:7px;
        height:7px;
        border-radius:999px;
        background:rgba(56,189,248,.9);
        box-shadow:0 0 12px rgba(56,189,248,.9);
      }
      .k{
        font-size:1.7rem;
        font-weight:800;
        letter-spacing:.02em;
      }
      .k-sub{
        font-size:.68rem;
        color:rgba(148,163,184,.85);
      }

      .boton-morado,
      .boton-negro{
        border-radius:12px;
        font-weight:700;
        transition:all .2s ease;
        display:inline-flex;
        align-items:center;
        justify-content:center;
        gap:.35rem;
        text-decoration:none;
      }
      .boton-morado{
        background:linear-gradient(135deg,#4f46e5,#06b6d4);
        color:white;
        box-shadow:0 14px 35px rgba(15,23,42,.9);
      }
      .boton-morado:hover{
        filter:brightness(1.05);
        transform:translateY(-1px);
        box-shadow:0 20px 45px rgba(15,23,42,1);
      }
      .boton-negro{
        background:rgba(15,23,42,.8);
        border:1px solid rgba(148,163,184,.5);
        color:white;
      }
      .boton-negro:hover{
        background:rgba(15,23,42,1);
        border-color:rgba(248,250,252,.7);
        transform:translateY(-1px);
      }
      .boton-mini{
        padding:8px 14px;
        font-size:.78rem;
      }

      .mensaje-exito{
        background:linear-gradient(135deg,#16a34a,#22c55e);
        color:white;
        padding:12px 14px;
        border-radius:10px;
        margin-bottom:18px;
        font-size:.85rem;
        display:flex;
        align-items:flex-start;
        gap:.4rem;
      }
      .mensaje-exito::before{
        content:"✓";
        font-weight:bold;
        margin-right:.25rem;
      }

      .card-panel{
        border-radius:22px;
        padding:18px 18px 20px;
        background:radial-gradient(circle at top left,rgba(56,189,248,.18),rgba(15,23,42,.96));
        border:1px solid rgba(148,163,184,.4);
        box-shadow:0 20px 60px rgba(0,0,0,.8);
      }

      .pendiente-item{
        padding:14px 14px;
        border-radius:14px;
        background:rgba(15,23,42,.95);
        border:1px solid rgba(148,163,184,.35);
        display:flex;
        justify-content:space-between;
        align-items:flex-start;
        gap:12px;
      }
      .pendiente-item:hover{
        border-color:rgba(56,189,248,.8);
        background:radial-gradient(circle at top left,rgba(56,189,248,.12),rgba(15,23,42,1));
      }

      .pill-status{
        padding:3px 8px;
        border-radius:999px;
        font-size:.7rem;
        text-transform:uppercase;
        letter-spacing:.16em;
        border:1px solid rgba(250,204,21,.7);
        color:#facc15;
        background:rgba(23,23,23,.4);
      }
      .pill-green-dot{
        width:6px;
        height:6px;
        border-radius:999px;
        background:#22c55e;
        box-shadow:0 0 10px rgba(34,197,94,.9);
      }
    </style>
</head>

<body class="text-white">

<!-- HEADER -->
<header class="sticky top-0 z-30 lp-admin-header">
  <div class="max-w-6xl mx-auto px-4 md:px-5 py-3 flex items-center justify-between">
    <a href="PanelAdmin.jsp" class="flex items-center gap-2 font-extrabold tracking-tight select-none">
      <span class="inline-block w-2.5 h-2.5 rounded-sm bg-emerald-400"></span>
      <span>LivePassBuga</span>
      <span class="text-xs font-semibold uppercase tracking-[0.28em] text-teal-300/80 hidden sm:inline">
        Admin
      </span>
    </a>

    <nav class="hidden sm:flex items-center gap-5 text-white/80 text-[0.85rem]">
      <span class="uppercase tracking-[0.18em] text-[0.62rem] text-white/60">
        LISTADOS
      </span>
      <a href="ListarTodosClientes.jsp" class="hover:text-white transition">Clientes</a>
      <a href="ListarTodosOrganizadores.jsp" class="hover:text-white transition">Organizadores</a>
      <a href="ListarTodosEventos.jsp" class="hover:text-white transition">Eventos</a>
      <a href="ListarTodosTickets.jsp" class="hover:text-white transition">Tickets</a>
      <a href="<%= request.getContextPath() %>/Control/ct_logout_admin.jsp"
         class="px-4 py-2 rounded-xl border border-white/20 hover:border-white/60 text-[0.8rem]">
        Cerrar sesión
      </a>
    </nav>
  </div>
</header>

<main class="max-w-6xl mx-auto px-4 md:px-5 py-8 md:py-10">

  <!-- HEADER PANEL -->
  <section class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
    <div>
      <div class="lp-pill mb-2">
        Panel principal · Administrador
      </div>
      <h1 class="text-3xl md:text-4xl font-extrabold leading-tight">
        Hola, <span class="text-cyan-300"><%= name %></span>
      </h1>
      <p class="text-white/70 mt-1 text-sm max-w-xl">
        Controla la actividad de la plataforma: usuarios, organizadores, eventos y tickets
        en un solo lugar.
      </p>
    </div>

    <div class="flex flex-wrap gap-2 justify-start md:justify-end">
      <a href="AprobacionEventos.jsp" class="boton-morado boton-mini">
        Pendientes
      </a>
      <a href="CrearAdministrador.jsp" class="boton-negro boton-mini">
        Nuevo admin
      </a>
      <a href="Reportes.jsp" class="boton-negro boton-mini">
        Reportes
      </a>
      <a href="SoporteAdministrador.jsp" class="boton-negro boton-mini">
        PQRS
      </a>
    </div>
  </section>

  <% if (msgEvento != null) { %>
      <div class="mensaje-exito"><%= msgEvento %></div>
  <% } %>

  <!-- MÉTRICAS + RESUMEN -->
  <section class="grid lg:grid-cols-4 gap-4 mt-4 items-start">
    <div class="lg:col-span-3 grid grid-cols-1 sm:grid-cols-3 lg:grid-cols-5 gap-4">

      <div class="metric">
        <div class="metric-label">
          <span class="metric-dot"></span>
          <span>Usuarios</span>
        </div>
        <div class="k"><%= totalUsuarios %></div>
        <div class="k-sub">Clientes registrados</div>
      </div>

      <div class="metric">
        <div class="metric-label">
          <span class="metric-dot"></span>
          <span>Organizadores</span>
        </div>
        <div class="k"><%= totalOrganizadores %></div>
        <div class="k-sub">Productores / marcas</div>
      </div>

      <div class="metric">
        <div class="metric-label">
          <span class="metric-dot"></span>
          <span>Eventos</span>
        </div>
        <div class="k"><%= totalEventos %></div>
        <div class="k-sub">Activos e históricos</div>
      </div>

      <div class="metric">
        <div class="metric-label">
          <span class="metric-dot"></span>
          <span>Tickets</span>
        </div>
        <div class="k"><%= totalTickets %></div>
        <div class="k-sub">Entradas emitidas</div>
      </div>

      <div class="metric">
        <div class="metric-label">
          <span class="metric-dot"></span>
          <span>Comisiones</span>
        </div>
        <div class="k">$<%= totalComisiones %></div>
        <div class="k-sub">10% acumulado</div>
      </div>
    </div>

    <div class="card-panel text-sm">
      <div class="flex items-center justify-between mb-2">
        <p class="text-xs uppercase tracking-[0.18em] text-slate-300">
          Resumen rápido
        </p>
        <span class="inline-flex items-center gap-2 text-[0.7rem] text-slate-300">
          <span class="pill-green-dot"></span>
          <span>Plataforma estable</span>
        </span>
      </div>
      <p class="text-xs text-slate-200">
        Desde este panel podrás:
      </p>
      <ul class="mt-2 space-y-1.5 text-xs text-slate-200/90">
        <li>• Aprobar o rechazar nuevos eventos antes de su publicación.</li>
        <li>• Supervisar la base de usuarios y organizadores.</li>
        <li>• Revisar tickets emitidos y comisiones generadas.</li>
      </ul>
      <p class="mt-3 text-[0.7rem] text-slate-400">
        Tip: revisa el bloque de <strong>Eventos pendientes</strong> para no dejar lanzamientos sin respuesta.
      </p>
    </div>
  </section>

  <!-- EVENTOS PENDIENTES -->
  <section class="mt-12">
    <div class="flex items-center justify-between mb-2">
      <div>
        <p class="text-xs uppercase tracking-[0.2em] text-slate-400">
          Moderación
        </p>
        <h2 class="text-xl font-bold">Eventos pendientes de aprobación</h2>
        <p class="text-white/60 text-xs mt-1">
          Máximo 5 próximos eventos por aprobar. Revisa título y lugar y decide rápido.
        </p>
      </div>

      <div class="hidden sm:flex flex-col items-end text-right">
        <span class="pill-status">
          <% if (pendientes != null) { %>
              <%= pendientes.size() %> en cola
          <% } else { %>
              0 en cola
          <% } %>
        </span>
        <span class="text-[0.7rem] text-slate-400 mt-1">
          Ver más en <a href="AprobacionEventos.jsp" class="underline decoration-dotted">Aprobación de eventos</a>
        </span>
      </div>
    </div>

    <div class="mt-4">
      <% if (pendientes != null && !pendientes.isEmpty()) { %>
        <div class="space-y-3">
          <% for (Event ev : pendientes) { %>
            <div class="pendiente-item">
              <div class="flex-1 min-w-0">
                <div class="font-semibold text-sm truncate mb-1">
                  <%= ev.getTitle() != null ? ev.getTitle() : "Evento sin título" %>
                </div>
                <div class="text-[0.8rem] text-slate-300 flex flex-wrap gap-x-3 gap-y-1">
                  <span><strong>Lugar:</strong> <%= ev.getVenue() != null ? ev.getVenue() : "Por definir" %></span>
                  <% if (ev.getCity() != null) { %>
                    <span><strong>Ciudad:</strong> <%= ev.getCity() %></span>
                  <% } %>
                </div>
              </div>

              <div class="flex flex-col items-end gap-2">
                <div class="flex gap-2">
                  <a href="../Control/ct_aprobar_evento_backoffice.jsp?id=<%= ev.getId() %>&action=aprobar"
                     class="boton-morado boton-mini">
                    Aprobar
                  </a>
                  <a href="../Control/ct_aprobar_evento_backoffice.jsp?id=<%= ev.getId() %>&action=rechazar"
                     class="boton-negro boton-mini">
                    Rechazar
                  </a>
                </div>
                <a href="DetalleEventoAdmin.jsp?id=<%= ev.getId() %>"
                   class="text-[0.75rem] text-slate-300 hover:text-cyan-300 underline decoration-dotted">
                  Ver detalles del evento
                </a>
              </div>
            </div>
          <% } %>
        </div>
      <% } else { %>
        <div class="card-panel mt-2 text-sm text-slate-200">
          <p>No hay eventos pendientes de aprobación.</p>
          <p class="mt-1 text-[0.8rem] text-slate-400">
            Cuando los organizadores creen nuevos conciertos o festivales, aparecerán aquí para que los revises.
          </p>
        </div>
      <% } %>
    </div>
  </section>

</main>
</body>
</html>
