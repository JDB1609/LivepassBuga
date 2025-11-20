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
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-6xl mx-auto px-5 py-10">
    <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-4 mb-6">
      <div>
        <h1 class="text-2xl font-extrabold">Mis eventos</h1>
        <p class="text-white/60">Crea, publica y administra tus eventos</p>
      </div>

      <div class="flex items-center gap-2">
        <form action="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp"
              method="get" class="flex items-center gap-2">
          <input name="q"
                 value="<%= (String)request.getAttribute("f_q")!=null ? (String)request.getAttribute("f_q") : "" %>"
                 placeholder="Buscar evento..."
                 class="px-4 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary" />
          <select name="status"
                  class="px-3 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary">
            <%
              String stSel = (String) request.getAttribute("f_status");
              boolean stAll = (stSel==null || stSel.isBlank());
            %>
            <option value="" <%= stAll ? "selected" : "" %>>Todos</option>
            <option value="PUBLICADO" <%= "PUBLICADO".equalsIgnoreCase(stSel) ? "selected" : "" %>>Publicado</option>
            <option value="BORRADOR"  <%= "BORRADOR".equalsIgnoreCase(stSel)  ? "selected" : "" %>>Borrador</option>
            <option value="FINALIZADO" <%= "FINALIZADO".equalsIgnoreCase(stSel)? "selected" : "" %>>Finalizado</option>
            <option value="PENDIENTE" <%= "PENDIENTE".equalsIgnoreCase(stSel)? "selected" : "" %>>Pendiente</option>
            <option value="RECHAZADO" <%= "RECHAZADO".equalsIgnoreCase(stSel)? "selected" : "" %>>Rechazado</option>
            <option value="CANCELADO" <%= "CANCELADO".equalsIgnoreCase(stSel)? "selected" : "" %>>Cancelado</option>
          </select>
          <button class="btn-primary ripple" type="submit">Filtrar</button>
        </form>

        <a href="<%= request.getContextPath() %>/Vista/EventoNuevo.jsp"
           class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30 font-bold transition">
          + Crear evento
        </a>
      </div>
    </div>

    <jsp:include page="../Control/ct_event_list.jsp" />

    <%
      List<Event> events = (List<Event>) request.getAttribute("events");
      DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    %>

    <section class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
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
                    ? "bg-white text-black"
                : "bg-yellow-500/20 text-yellow-200";

            /* Acciones permitidas */
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
                break; // no permitir nada
            }
            String dateStr    = (ev.getDateTime()!=null) ? ev.getDateTime().format(df) : ev.getDate();
            String evTitle    = ev.getTitle()!=null ? ev.getTitle() : "";
            String evTitleJs  = evTitle.replace("'", "\\'");
      %>
      <article class="glass ring rounded-2xl p-6 animate-fadeUp" style="animation-delay:<%= (idx * 0.06) %>s">
        <div class="flex items-center justify-between mb-2">
          <h3 class="font-bold text-lg"><%= evTitle %></h3>
          <span class="px-2.5 py-1 rounded-full text-xs font-bold <%= pill %>"><%= status %></span>
        </div>

        <p class="text-white/70">📅 <%= dateStr %></p>
        <p class="text-white/70">📍 <%= ev.getVenue()!=null?ev.getVenue():"" %></p>
        <div class="flex items-center gap-3 mt-3 text-sm text-white/70">
          <span>👥 Capacidad: <%= ev.getCapacity() %></span>
          <span>•</span>
          <span>🎫 Vendidas: <%= ev.getSold() %></span>
        </div>
        <p class="mt-2 font-extrabold"><%= ev.getPriceFormatted() %></p>

        <div class="mt-5 flex flex-wrap gap-2">
          <!-- Panel siempre visible -->
          <a class="btn-primary ripple"
             href="<%= request.getContextPath() %>/Vista/DashboardOrganizador.jsp?eventId=<%= ev.getId() %>">
            Panel
          </a>

          <% if (canSendReview) { %>
            <a class="px-4 py-2 rounded-lg bg-blue-500/20 text-blue-200 hover:bg-blue-500/30 font-bold transition"
               href="<%= request.getContextPath() %>/Control/ct_event_send_review.jsp?id=<%= ev.getId() %>">
              Enviar a revisión
            </a>
          <% } %>

          <% if (canEdit) { %>
            <a class="px-4 py-2 rounded-lg border border-white/15 hover:border-white/30 font-bold transition"
               href="<%= request.getContextPath() %>/Vista/EventoEditar.jsp?id=<%= ev.getId() %>">
              Editar
            </a>
          <% } %>

          <% if (canDelete) { %>
            <a class="px-4 py-2 rounded-lg border border-pink-500/40 text-pink-300 hover:border-pink-300 font-bold transition"
               href="<%= request.getContextPath() %>/Control/ct_event_delete.jsp?id=<%= ev.getId() %>"
               onclick="return confirm('¿Eliminar el evento \\\"<%= evTitleJs %>\\\"? Esta acción no se puede deshacer.');">
              Eliminar
            </a>
          <% } %>
        </div>
      </article>
      <%
          } // for
        } else {
      %>
      <div class="col-span-full glass ring rounded-2xl p-8 text-center text-white/70">
        No hay eventos para mostrar.
      </div>
      <% } %>
    </section>
  </main>
</body>
</html>
