<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, utils.User, dao.UserDAO" %>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/Vista/LoginAdmin.jsp");
        return;
    }

    List<User> organizadores = null;
    try {
        UserDAO dao = new UserDAO();
        organizadores = dao.listAllOrganizers();   // Método correcto
    } catch (Exception e) {
        e.printStackTrace();
    }

    int totalOrganizadores = (organizadores != null) ? organizadores.size() : 0;
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base_administrador.jspf" %>
    <title>Organizadores — LivePassBuga</title>

<style>
    body {
        background:#050816;
        color:#f9fafb;
        font-family:system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }

    .page {
        max-width:1100px;
        margin:34px auto;
        padding:0 18px;
    }

    /* PILL */
    .lp-pill {
        font-size:0.68rem;
        text-transform:uppercase;
        letter-spacing:0.22em;
        padding:0.22rem 0.8rem;
        border-radius:999px;
        border:1px solid rgba(148,163,184,.7);
        background:rgba(15,23,42,.9);
        color:#e5e7eb;
        display:inline-flex;
        align-items:center;
        gap:.4rem;
    }
    .lp-pill-dot {
        width:6px; height:6px;
        border-radius:999px;
        background:#ffb703;
        box-shadow:0 0 10px rgba(255,183,3,.85);
    }

    /* HEADER */
    .header-main {
        display:flex;
        justify-content:space-between;
        align-items:flex-end;
        flex-wrap:wrap;
        gap:14px;
        margin-bottom:18px;
    }
    .header-main h1 {
        margin:0;
        font-size:1.8rem;
        font-weight:800;
    }
    .header-main p {
        margin:4px 0 0 0;
        color:rgba(226,232,240,.78);
        font-size:.9rem;
    }
    .header-meta {
        text-align:right;
        color:rgba(148,163,184,.9);
        font-size:.8rem;
    }
    .header-meta strong {
        font-size:1.3rem;
        color:#e5e7eb;
    }

    /* RESUMEN */
    .summary {
        margin-top:14px;
        margin-bottom:16px;
        padding:12px 16px;
        border-radius:16px;
        background:radial-gradient(circle at top left, rgba(255,183,3,.12), rgba(15,23,42,.96));
        border:1px solid rgba(255,183,3,.25);
        box-shadow:0 15px 40px rgba(0,0,0,.7);
        display:flex;
        justify-content:space-between;
        gap:14px;
        align-items:center;
        font-size:.85rem;
    }
    .summary span.label {
        text-transform:uppercase;
        font-size:.75rem;
        letter-spacing:.18em;
        color:rgba(209,213,219,.9);
    }
    .summary span.value {
        font-weight:800;
        margin-left:4px;
        color:#ffb703;
    }

    /* GRID CARDS */
    .grid {
        display:grid;
        grid-template-columns:repeat(auto-fill,minmax(280px,1fr));
        gap:20px;
        margin-top:16px;
    }

    a.card-link {
        text-decoration:none;
        color:inherit;
    }

    .card {
        background:rgba(15,23,42,0.96);
        border:1px solid rgba(255,255,255,0.08);
        padding:18px;
        border-radius:18px;
        box-shadow:0 18px 40px rgba(0,0,0,.7);
        transition:.18s;
        display:flex;
        flex-direction:column;
        gap:10px;
    }
    .card:hover {
        transform:translateY(-3px);
        border-color:#ffb703;
        box-shadow:0 25px 55px rgba(0,0,0,.9);
    }

    /* AVATAR */
    .avatar {
        width:38px; height:38px;
        border-radius:999px;
        background:linear-gradient(135deg,#ffb703,#fb8500);
        display:flex;
        align-items:center;
        justify-content:center;
        color:#000;
        font-weight:700;
        font-size:1rem;
    }

    .card-header {
        display:flex;
        align-items:center;
        justify-content:space-between;
    }

    .name-block {
        display:flex;
        align-items:center;
        gap:10px;
        overflow:hidden;
    }

    .name {
        font-weight:700;
        font-size:1rem;
        white-space:nowrap;
        overflow:hidden;
        text-overflow:ellipsis;
    }

    .badge {
        background:#ffb703;
        color:#000;
        padding:4px 10px;
        border-radius:999px;
        font-size:.75rem;
        font-weight:700;
        letter-spacing:.12em;
    }

    .card-body p {
        margin:3px 0;
        font-size:.88rem;
        color:#e5e7eb;
    }

    .footer {
        font-size:.75rem;
        color:rgba(148,163,184,.8);
        margin-top:6px;
    }
</style>
</head>

<body>
<%@ include file="../Includes/nav_base_administrador.jspf" %>

<main class="page">

    <!-- ENCABEZADO -->
    <section class="header-main">
        <div>
            <div class="lp-pill">
                <span class="lp-pill-dot"></span> Listado · Organizadores
            </div>
            <h1>Organizadores</h1>
            <p>Usuarios con permisos para crear, administrar y gestionar eventos.</p>
        </div>

        <div class="header-meta">
            <div>Total organizadores</div>
            <strong><%= totalOrganizadores %></strong>
        </div>
    </section>

    <!-- RESUMEN -->
    <section class="summary">
        <div>
            <span class="label">Organizadores activos:</span>
            <span class="value"><%= totalOrganizadores %></span>
        </div>
        <div style="text-align:right; color:rgba(209,213,219,.8);">
            Administran eventos, ventas de tickets y reportes.<br>
            Haz clic sobre un organizador para ver su perfil completo.
        </div>
    </section>

    <!-- GRID -->
    <section class="grid">
        <% for (User u : organizadores) {
            String nombre = (u.getName() != null) ? u.getName().trim() : "Sin nombre";
            String iniciales = "";
            if (!nombre.isEmpty()) {
                String[] partes = nombre.split(" ");
                iniciales = (partes.length == 1)
                        ? partes[0].substring(0,1).toUpperCase()
                        : (partes[0].substring(0,1) + partes[partes.length-1].substring(0,1)).toUpperCase();
            }
        %>

        <!-- CARD CLICKEABLE -->
        <a href="PerfilOrganizador.jsp?id=<%= u.getId() %>" class="card-link">
            <div class="card">

                <div class="card-header">
                    <div class="name-block">
                        <div class="avatar"><%= iniciales %></div>
                        <div class="name"><%= nombre %></div>
                    </div>
                    <span class="badge">ORGANIZADOR</span>
                </div>

                <div class="card-body">
                    <p><b>ID:</b> <%= u.getId() %></p>
                    <p><b>Email:</b> <%= u.getEmail() != null ? u.getEmail() : "-" %></p>
                    <p><b>Tel:</b> <%= u.getPhone() != null ? u.getPhone() : "-" %></p>
                </div>

                <div class="footer">Clic para ver perfil, eventos y actividad.</div>
            </div>
        </a>

        <% } %>
    </section>

</main>
</body>
</html>
