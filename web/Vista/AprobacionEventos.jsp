<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, utils.Event, dao.EventDAO" %>

<%
String role = (String) session.getAttribute("role");
if (role == null || !"ADMIN".equals(role)) {
    response.sendRedirect(request.getContextPath() + "/Vista/LoginAdmin.jsp");
    return;
}

int pagina = 1;
try { pagina = Integer.parseInt(request.getParameter("page")); } catch (Exception ignore) {}

int pageSize = 10;
int offset = (pagina - 1) * pageSize;

EventDAO dao = new EventDAO();

int total = dao.countPending();
List<Event> pending = dao.listPendingPaged(pageSize, offset);

int totalPaginas = (int) Math.ceil(total / (double) pageSize);

// 🔥 AHORA LOS MENSAJES VIENEN POR GET, NO POR request.setAttribute
String msg = request.getParameter("msg");
String msgType = request.getParameter("type");
%>

<!DOCTYPE html>
<html lang="es">
<head>
<title>Aprobación de Eventos</title>

<style>
/* --- TU CSS ORIGINAL COMPLETO (NO MODIFICADO) --- */

body{
    background:#0b1020;
    color:white;
    font-family: inter, system-ui, sans-serif;
    margin:0;
}

header{
    position:sticky; top:0; z-index:30;
    backdrop-filter:blur(6px);
    background:#0b0e16;
    border-bottom:1px solid rgba(255,255,255,0.12);
}

.header-inner{
    max-width:1200px;
    margin:auto;
    padding:12px 24px;
    display:flex;
    align-items:center;
    justify-content:space-between;
    position:relative;
}

.logo{
    display:flex;
    align-items:center;
    gap:8px;
    font-weight:800;
    text-decoration:none;
    color:white;
    font-size:1.1rem;
}

.logo-dot{
    width:12px; height:12px; border-radius:3px;
    background:#00d1b2;
    display:inline-block;
}

.center-link{
    position:absolute;
    left:50%; transform:translateX(-50%);
    font-weight:700;
    color:white;
    padding:6px 14px;
    border-radius:10px;
    border:1px solid rgba(255,255,255,0.20);
    text-decoration:none;
}
.center-link:hover{
    background:white; color:black;
}

.logout{
    padding:6px 16px;
    border-radius:10px;
    border:1px solid rgba(255,255,255,0.15);
    text-decoration:none;
    color:white;
}
.logout:hover{
    background:#ff4b4b;
    border-color:#ff4b4b;
}

.container{
    max-width:1200px;
    margin:36px auto;
    padding:20px;
}

/* TARJETAS */
.event-grid{
    display:grid;
    grid-template-columns:repeat(auto-fill, minmax(320px, 1fr));
    gap:24px;
    margin-top:25px;
}

.event-card{
    background:rgba(255,255,255,0.04);
    border:1px solid rgba(255,255,255,0.08);
    border-radius:16px;
    overflow:hidden;
    display:flex;
    flex-direction:column;
    transition:0.2s;
}

.event-card:hover{
    transform:translateY(-4px);
    background:rgba(255,255,255,0.06);
}

.event-img{
    width:100%;
    height:180px;
    object-fit:cover;
    background:#111826;
}

.event-content{
    padding:18px;
}

.event-title{
    margin:0 0 8px 0;
    font-size:1.25rem;
    font-weight:800;
}

.event-line{
    margin:5px 0;
    font-size:.92rem;
    color:rgba(230,230,230,0.88);
}

.event-desc{
    margin-top:8px;
    color:rgba(255,255,255,0.75);
    font-size:.9rem;
    height:42px;
    overflow:hidden;
    text-overflow:ellipsis;
}

.card-actions{
    display:flex;
    gap:10px;
    margin-top:15px;
}

.btn-approve{
    flex:1;
    padding:10px;
    border-radius:12px;
    font-weight:800;
    text-align:center;
    background:#8c4bff;
    color:white;
    text-decoration:none;
    border:none;
    transition:.2s;
}
.btn-approve:hover{
    filter:brightness(1.2);
}

.btn-reject{
    flex:1;
    padding:10px;
    border-radius:12px;
    font-weight:800;
    text-align:center;
    background:#ff3b3b;
    color:white;
    text-decoration:none;
    transition:.2s;
}
.btn-reject:hover{
    filter:brightness(1.2);
}

.pagination{
    text-align:center;
    margin-top:35px;
}
.pagination a{
    margin:0 4px;
    padding:8px 14px;
    border-radius:10px;
    background:rgba(255,255,255,0.05);
    border:1px solid rgba(255,255,255,0.15);
    color:white;
    font-weight:700;
    text-decoration:none;
}
.pagination .active{
    background:white; 
    color:black;
}

/* ALERTA */
.alert-success{
    background:#0dbb74;
    padding:14px 20px;
    border-radius:10px;
    margin-bottom:20px;
    font-weight:700;
}

.alert-error{
    background:#ff5252;
    padding:14px 20px;
    border-radius:10px;
    margin-bottom:20px;
    font-weight:700;
}
</style>
</head>

<body>

<header>
    <div class="header-inner">
        <a href="#" class="logo">
            <span class="logo-dot"></span> Livepass <span style="color:#00d1b2;">Buga</span>
        </a>

        <a href="<%=request.getContextPath()%>/Vista/BackofficeAdministrador.jsp" 
           class="center-link">← Volver al Dashboard</a>

        <a href="<%=request.getContextPath()%>/Control/ct_logout_admin.jsp" class="logout">Salir</a>
    </div>
</header>

<div class="container">
    <h1>Eventos Pendientes</h1>
    <div class="small">Aprueba o rechaza los eventos enviados por los organizadores</div>

    <!-- 🔥 MOSTRAR MENSAJES (AHORA FUNCIONA PORQUE VIENE POR GET) -->
    <% if (msg != null) { %>
        <div class="<%= "success".equals(msgType) ? "alert-success" : "alert-error" %>">
            <%= msg %>
        </div>
    <% } %>

    <div class="event-grid">

        <% if (pending != null && !pending.isEmpty()) {
           for (Event ev : pending) { %>

        <div class="event-card">

            <%System.out.println("DEBUG IMG -> Valor en BD: " + ev.getImage()); %>
            <img class="event-img" referrerpolicy="no-referrer" crossorigin="anonymous" src="<%= ev.getImage() %>" alt="Imagen Evento">

            <div class="event-content">
                <div class="event-title"><%= ev.getTitle() %></div>

                <div class="event-line">📍 <%= ev.getCity() %></div>
                <div class="event-line">🏛 <%= ev.getVenue() %></div>
                <div class="event-line">📅 <%= ev.getDate() %></div>
                <div class="event-line">💲 <%= ev.getPriceFormatted() %></div>

                <div class="event-desc"><%= ev.getDescription() %></div>

                <div class="card-actions"> 
                    <a class="btn-approve" 
                       href="<%= request.getContextPath() %>/Control/ct_Aprobacion_Eventos.jsp?id=<%= ev.getId() %>&accion=aprobar">
                       Aprobar
                    </a>

                    <a class="btn-reject" 
                       href="<%= request.getContextPath() %>/Control/ct_Aprobacion_Eventos.jsp?id=<%= ev.getId() %>&accion=rechazar">
                       Rechazar
                    </a>
                </div>
            </div>

        </div>

        <% }} else { %>

        <p style="opacity:.8; text-align:center;">No hay eventos pendientes.</p>

        <% } %>

    </div>

    <div class="pagination">
        <% for (int i = 1; i <= totalPaginas; i++) { %>
            <a href="?page=<%=i%>" class="<%= (i == pagina ? "active" : "") %>"><%= i %></a>
        <% } %>
    </div>

</div>

</body>
</html>