<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, utils.SoporteMensaje, dao.SoporteDAO" %>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/Vista/LoginAdmin.jsp");
        return;
    }

    String filtro = request.getParameter("filtro");
    if (filtro == null) filtro = "todos";

    SoporteDAO dao = new SoporteDAO();
    List<SoporteMensaje> mensajes = null;

    if ("pendientes".equals(filtro)) {
        mensajes = dao.listarPendientes();
    } else if ("atendidos".equals(filtro)) {
        mensajes = dao.listarAtendidos();
    } else {
        mensajes = dao.listarTodos();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base_administrador.jspf" %>
    <title>Soporte — Administración</title>

<style>
    body { background:#0b1020; color:#fff; font-family: inter, system-ui, sans-serif; }
    .container{ max-width:1100px; margin:36px auto; padding:20px; }

    .cards-grid{
        display:grid;
        grid-template-columns: repeat(auto-fill, minmax(280px,1fr));
        gap:18px;
    }

    .support-card{
        background: rgba(255,255,255,0.04);
        border:1px solid rgba(255,255,255,0.08);
        border-radius:14px;
        padding:16px;
    }

    .card-header{
        display:flex;
        justify-content:space-between;
        font-weight:800;
        margin-bottom:10px;
    }

    .badge{
        padding:4px 10px;
        border-radius:999px;
        font-size:.8rem;
        font-weight:700;
    }

    .PENDIENTE{ background:#ffb703; color:#000; }
    .ATENDIDA{ background:#00d1b2; color:#003; }

    .card-body p{ margin:6px 0; font-size:.92rem; }

    .card-actions{
        display:flex;
        gap:10px;
        justify-content:flex-end;
        margin-top:14px;
    }

    .btn{ padding:8px 12px; border-radius:10px; font-weight:700; cursor:pointer; }
    .btn-edit{ background:transparent; border:1px solid rgba(255,255,255,0.12); color:#fff; }
    .btn-save{ background:#00d1b2; color:#032; border:0; }

    textarea{
        width:100%;
        padding:10px;
        border-radius:8px;
        background:transparent;
        border:1px solid rgba(255,255,255,0.15);
        color:#fff;
        resize:none;
    }

    .filter-bar{
        display:flex;
        gap:12px;
        margin-bottom:18px;
        flex-wrap:wrap;
    }

    .filter-bar a{
        padding:6px 14px;
        border-radius:999px;
        border:1px solid rgba(255,255,255,0.14);
        color:white;
        text-decoration:none;
    }

    .filter-active{ background:#00d1b2; color:#003!important; }

    .edit-card{ display:none; }
    .edit-card.show{ display:block; }
    .info-card.hidden{ display:none; }

    .msg{ padding:10px; border-radius:8px; margin-bottom:12px; }
    .ok{ background: rgba(0,209,178,0.12); color:#bfffe8; border:1px solid rgba(0,209,178,0.18); }
    .err{ background: rgba(255,80,80,0.08); color:#ffd7d7; border:1px solid rgba(255,80,80,0.12); }
</style>
</head>

<body>
<%@ include file="../Includes/nav_base_administrador.jspf" %>

<div class="container">

    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
        <div>
            <h1 style="margin:0">Soporte</h1>
            <div class="small">Mensajes de contacto</div>
        </div>
    </div>

    <!-- ✅ FILTROS -->
    <div class="filter-bar">
        <a href="?filtro=todos" class="<%= "todos".equals(filtro) ? "filter-active" : "" %>">Todos</a>
        <a href="?filtro=pendientes" class="<%= "pendientes".equals(filtro) ? "filter-active" : "" %>">Pendientes</a>
        <a href="?filtro=atendidos" class="<%= "atendidos".equals(filtro) ? "filter-active" : "" %>">Atendidos</a>
    </div>

    <% String msg = request.getParameter("msg");
       if ("ok".equals(msg)) { %>
        <div class="msg ok">Respuesta enviada correctamente ✅</div>
    <% } else if ("err".equals(msg)) { %>
        <div class="msg err">Error enviando la respuesta ❌</div>
    <% } %>

    <% if (mensajes == null || mensajes.isEmpty()) { %>
        <div class="msg" style="background:rgba(255,183,3,0.1); color:#ffb703; border:1px solid rgba(255,183,3,0.2);">
            ⚠️ No hay mensajes para mostrar con el filtro "<%= filtro %>"
        </div>
    <% } %>

    <div class="cards-grid">

    <% if (mensajes != null) {
        for (SoporteMensaje s : mensajes) { %>

        <!-- ✅ TARJETA INFO -->
        <div class="support-card info-card" id="info-<%= s.getId() %>">

            <div class="card-header">
                <strong><%= s.getNombre() %></strong>

                <span class="badge <%= s.getEstado() %>"><%= s.getEstado() %></span>
            </div>

            <div class="card-body">
                <p><b>ID del mensaje:</b> <%= s.getId() %></p>
                <p><b>Fecha del reporte:</b> <%= s.getFecha() %></p>
                <p><b>Email:</b> <%= s.getEmail() %></p>
                <p><b>Mensaje:</b> <%= s.getMensaje() %></p>

                <% if (s.getRespuesta() != null) { %>
                    <p><b>Respuesta:</b> <%= s.getRespuesta() %></p>
                <% } %>
            </div>

            <% if (s.getEstado() == SoporteMensaje.Estado.PENDIENTE) { %>
            <div class="card-actions">
                <button class="btn btn-edit" onclick="showEdit(<%= s.getId() %>)">Responder</button>
            </div>
            <% } %>

        </div>

        <!-- ✅ TARJETA RESPUESTA -->
        <div class="support-card edit-card" id="edit-<%= s.getId() %>">

            <form action="<%= request.getContextPath() %>/Control/ct_responder_soporte.jsp" method="post">

                <input type="hidden" name="id" value="<%= s.getId() %>">

                <div style="margin-bottom:10px;">
                    <b>Responder a:</b> <%= s.getEmail() %>
                </div>

                <textarea name="respuesta" rows="4" required></textarea>

                <div class="card-actions">
                    <button type="button" class="btn btn-edit" onclick="hideEdit(<%= s.getId() %>)">Cancelar</button>
                    <button type="submit" class="btn btn-save">Enviar</button>
                </div>

            </form>
        </div>

    <% }
    } %>

    </div>
</div>

<script>
    function showEdit(id){
        document.getElementById("info-"+id).classList.add("hidden");
        document.getElementById("edit-"+id).classList.add("show");
    }

    function hideEdit(id){
        document.getElementById("info-"+id).classList.remove("hidden");
        document.getElementById("edit-"+id).classList.remove("show");
    }
</script>

</body>
</html>