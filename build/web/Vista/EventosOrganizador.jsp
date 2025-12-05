<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, java.time.format.DateTimeFormatter" %>
<%@ page import="utils.Event" %>
<%
  Integer uid = (Integer) session.getAttribute("userId");
  String role = (String) session.getAttribute("role");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }
  if (role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath()+"/Vista/HomeCliente.jsp"); return;
  }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Mis eventos — Organizador</title>

  <style>
    body{
      background: radial-gradient(circle at top,#111827 0,#020617 45%);
      font-family: Inter, ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
      -webkit-font-smoothing: antialiased;
      color: #e5e7eb;
    }
    .glass-card{
      background: linear-gradient(150deg, rgba(15,23,42,.96), rgba(15,23,42,.92));
      border-radius: 18px;
      border: 1px solid rgba(148,163,184,.28);
      box-shadow: 0 18px 45px rgba(0,0,0,.8);
      transition: transform .18s ease-out, box-shadow .18s ease-out, border-color .18s ease-out;
    }
    .glass-card:hover{
      transform: translateY(-2px);
      box-shadow: 0 24px 65px rgba(0,0,0,.95);
      border-color: rgba(45,212,191,.7);
    }
    .btn-primary{
      background: linear-gradient(90deg,#6366f1,#22cfd6);
      color:#fff;
      padding:.55rem 1.1rem;
      border-radius:999px;
      font-weight:700;
      font-size:.85rem;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      gap:.25rem;
      box-shadow:0 10px 30px rgba(79,70,229,.7);
    }
    .btn-primary:hover{
      filter:brightness(1.05);
      transform: translateY(-0.5px);
    }
    .btn-secondary{
      border-radius:999px;
      padding:.45rem .95rem;
      font-weight:600;
      font-size:.8rem;
      border:1px solid rgba(148,163,184,.4);
      background:rgba(15,23,42,.7);
      color:#e5e7eb;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      gap:.25rem;
    }
    .btn-secondary:hover{
      border-color:#e5e7eb;
    }
    .status-pill{
      font-size:.68rem;
      padding:.25rem .7rem;
      border-radius:999px;
      font-weight:700;
      text-transform:uppercase;
      letter-spacing:.06em;
    }
    .status-dot{
      width:8px;
      height:8px;
      border-radius:999px;
      display:inline-block;
      margin-right:.35rem;
    }
    .card-header{
      border-bottom:1px solid rgba(148,163,184,.24);
    }
    .search-input,
    .filter-select{
      background:rgba(15,23,42,.8);
      border-radius:999px;
      border:1px solid rgba(148,163,184,.35);
      padding:.5rem .9rem;
      font-size:.85rem;
      color:#e5e7eb;
    }
    .search-input::placeholder{
      color:rgba(148,163,184,.9);
    }
    .search-input:focus,
    .filter-select:focus{
      outline:none;
      border-color:rgba(45,212,191,.9);
      box-shadow:0 0 0 1px rgba(45,212,191,.5);
    }
    .badge-soft{
      padding:.18rem .55rem;
      border-radius:999px;
      border:1px solid rgba(148,163,184,.45);
      font-size:.68rem;
      text-transform:uppercase;
      letter-spacing:.06em;
      color:#e5e7eb;
      background:rgba(15,23,42,.85);
    }
    .card-actions a{
      white-space:nowrap;
    }
  </style>
</head>

<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-6xl mx-auto px-5 py-10">
    <!-- HEADER -->
    <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-4 mb-8">
      <div>
        <div class="flex items-center gap-2 mb-2">
          <span class="badge-soft">Mis eventos</span>
          <span class="text-xs text-emerald-300/80">
            Administra todo lo que tienes publicado y en borrador.
          </span>
        </div>
        <h1 class="text-3xl font-extrabold tracking-tight">Panel de eventos</h1>
        <p class="text-white/60 text-sm mt-1">
          Crea, publica, revisa y controla el estado de cada evento desde un solo lugar.
        </p>
      </div>

      <div class="flex flex-col items-stretch gap-3 md:items-end">
        <form action="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp"
              method="get"
              class="flex flex-wrap items-center gap-2 justify-end">
          <input name="q"
                 value="<%= (String)request.getAttribute("f_q")!=null ? (String)request.getAttribute("f_q") : "" %>"
                 placeholder="Buscar por nombre..."
                 class="search-input" />

          <select name="status" class="filter-select">
            <%
              String stSel = (String) request.getAttribute("f_status");
              boolean stAll = (stSel==null || stSel.isBlank());
            %>
            <option value="" <%= stAll ? "selected" : "" %>>Todos los estados</option>
            <option value="PUBLICADO" <%= "PUBLICADO".equalsIgnoreCase(stSel) ? "selected" : "" %>>Publicado</option>
            <option value="BORRADOR"  <%= "BORRADOR".equalsIgnoreCase(stSel)  ? "selected" : "" %>>Borrador</option>
            <option value="FINALIZADO" <%= "FINALIZADO".equalsIgnoreCase(stSel)? "selected" : "" %>>Finalizado</option>
            <option value="PENDIENTE" <%= "PENDIENTE".equalsIgnoreCase(stSel)? "selected" : "" %>>Pendiente</option>
            <option value="RECHAZADO" <%= "RECHAZADO".equalsIgnoreCase(stSel)? "selected" : "" %>>Rechazado</option>
            <option value="CANCELADO" <%= "CANCELADO".equalsIgnoreCase(stSel)? "selected" : "" %>>Cancelado</option>
          </select>

          <button class="btn-primary" type="submit">
            Filtrar
          </button>
        </form>

        <a href="<%= request.getContextPath() %>/Vista/EventoNuevo.jsp"
           class="btn-secondary">
          + Crear nuevo evento
        </a>
      </div>
    </div>

    <jsp:include page="../Control/ct_event_list.jsp" />

    <%
      List<Event> events = (List<Event>) request.getAttribute("events");
      DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    %>

    <!-- GRID DE TARJETAS -->
    <section class="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
      <%
        if (events != null && !events.isEmpty()) {
          for (int idx = 0; idx < events.size(); idx++) {
            Event ev = events.get(idx);
            String status = (ev.getStatus()==null) ? "" : ev.getStatus().toString();

            String pill =
                "PUBLICADO".equalsIgnoreCase(status)
                    ? "bg-emerald-500/20 text-emerald-200"
                : ("RECHAZADO".equalsIgnoreCase(status) || "CANCELADO".equalsIgnoreCase(status))
                    ? "bg-red-500/20 text-red-200"
                : "FINALIZADO".equalsIgnoreCase(status)
                    ? "bg-slate-100 text-slate-900"
                : "bg-amber-500/20 text-amber-200";

            String dotColor =
                "PUBLICADO".equalsIgnoreCase(status)
                    ? "bg-emerald-400"
                : ("RECHAZADO".equalsIgnoreCase(status) || "CANCELADO".equalsIgnoreCase(status))
                    ? "bg-red-400"
                : "FINALIZADO".equalsIgnoreCase(status)
                    ? "bg-slate-300"
                : "bg-amber-300";

            // Acciones permitidas
            boolean canSendReview = false;
            boolean canEdit = false;
            boolean canDelete = false;

            switch (status.toUpperCase()) {
              case "BORRADOR":
                canSendReview = true;
                canEdit = true;
                canDelete = true;
                break;
              case "PUBLICADO":
                canDelete = true; // cancelar publicación
                break;
              case "PENDIENTE":
                canDelete = true; // cancelar publicación
                canEdit = true;
                break;
              case "RECHAZADO":
              case "FINALIZADO":
              case "CANCELADO":
              default:
                break;
            }

            String dateStr   = (ev.getDateTime()!=null) ? ev.getDateTime().format(df) : ev.getDate();
            String evTitle   = ev.getTitle()!=null ? ev.getTitle() : "";
            String evTitleJs = evTitle.replace("'", "\\'");

            // URL de imagen (ajusta el getter según tu clase Event)
            String imgUrl = null;
            try {
              imgUrl = (String) ev.getClass().getMethod("getImage").invoke(ev);
            } catch (Exception ignore) {
              imgUrl = null;
            }
      %>

      <article class="glass-card overflow-hidden animate-fadeUp"
               style="animation-delay:<%= (idx * 0.06) %>s">
        <!-- IMAGEN -->
        <div class="relative aspect-video w-full bg-slate-900">
          <% if (imgUrl != null && !imgUrl.isBlank()) { %>
            <img src="<%= imgUrl %>"
                 alt="Portada de <%= evTitle %>"
                 class="w-full h-full object-cover"
                 loading="lazy">
            <div class="absolute inset-0 bg-gradient-to-t from-slate-950/80 via-slate-950/10 to-transparent"></div>
          <% } else { %>
            <div class="w-full h-full flex items-center justify-center text-xs text-white/60
                        bg-gradient-to-br from-slate-800 via-slate-900 to-slate-950">
              Sin imagen de portada
            </div>
          <% } %>

          <!-- Estado -->
          <span class="absolute top-3 right-3 status-pill <%= pill %> shadow-lg">
            <%= status %>
          </span>
        </div>

        <!-- CONTENIDO -->
        <div class="p-5 pb-4 card-header">
          <h3 class="font-bold text-lg line-clamp-2 mb-1"><%= evTitle %></h3>
          <p class="text-white/70 text-sm flex items-center gap-1">
            📅 <span><%= dateStr %></span>
          </p>
          <p class="text-white/70 text-sm flex items-center gap-1">
            📍 <span><%= ev.getVenue()!=null?ev.getVenue():"" %></span>
          </p>

          <div class="flex items-center gap-3 mt-3 text-xs text-white/70">
            <span>👥 Capacidad: <%= ev.getCapacity() %></span>
            <span>•</span>
            <span>🎫 Vendidas: <%= ev.getSold() %></span>
          </div>

          <p class="mt-3 font-extrabold text-base text-emerald-300">
            <%= ev.getPriceFormatted() %>
          </p>
        </div>

        <!-- ACCIONES -->
        <div class="p-4 pt-3 flex flex-wrap gap-2 card-actions">
          <!-- Panel siempre visible -->
          <a class="btn-primary"
             href="<%= request.getContextPath() %>/Vista/DashboardOrganizador.jsp?eventId=<%= ev.getId() %>">
            Panel
          </a>

          <% if (canSendReview) { %>
            <a class="btn-secondary bg-blue-500/10 border-blue-400/50 text-blue-100 hover:bg-blue-500/20"
               href="<%= request.getContextPath() %>/Control/ct_event_send_review.jsp?id=<%= ev.getId() %>">
              Enviar a revisión
            </a>
          <% } %>

          <% if (canEdit) { %>
            <a class="btn-secondary hover:border-white/70"
               href="<%= request.getContextPath() %>/Vista/EventoEditar.jsp?id=<%= ev.getId() %>">
              Editar
            </a>
          <% } %>

          <% if (canDelete) { %>
            <a class="btn-secondary border-pink-500/60 text-pink-200 hover:bg-pink-500/10"
               href="<%= request.getContextPath() %>/Control/ct_event_delete.jsp?id=<%= ev.getId() %>"
               onclick="return confirm('¿Eliminar el evento \\\"<%= evTitleJs %>\\\"? Esta acción no se puede deshacer.');">
              Eliminar
            </a>
          <% } %>

          <div class="ml-auto text-[0.7rem] text-white/50 flex items-center gap-1 mt-2 md:mt-0">
            <span class="status-dot <%= dotColor %>"></span>
            <span><%= status %></span>
          </div>
        </div>
      </article>

      <%
          } // for
        } else {
      %>
      <div class="col-span-full glass-card p-10 flex flex-col items-center justify-center text-center">
        <p class="text-white/70 mb-2 text-sm">
          Aún no tienes eventos creados.
        </p>
        <p class="text-xs text-white/50 mb-4">
          Crea tu primer evento y comenzará a aparecer aquí para que lo gestiones.
        </p>
        <a href="<%= request.getContextPath() %>/Vista/EventoNuevo.jsp" class="btn-primary">
          + Crear mi primer evento
        </a>
      </div>
      <% } %>
    </section>
  </main>
</body>
</html>
