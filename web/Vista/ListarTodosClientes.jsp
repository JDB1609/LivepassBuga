<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, utils.User, dao.UserDAO" %>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/Vista/LoginAdmin.jsp");
        return;
    }

    List<User> clientes = null;
    try {
        UserDAO dao = new UserDAO();
        clientes = dao.listAllClients();
    } catch (Exception e) {
        e.printStackTrace();
    }

    int totalClientes = (clientes != null) ? clientes.size() : 0;
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base_administrador.jspf" %>
    <title>Clientes — LivePassBuga</title>

    <style>
        body {
            background: #050816;
            color: #f9fafb;
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }

        .lp-page {
            max-width: 1100px;
            margin: 34px auto 40px auto;
            padding: 0 18px;
        }

        .lp-pill {
            font-size: 0.68rem;
            text-transform: uppercase;
            letter-spacing: 0.22em;
            padding: 0.18rem 0.8rem;
            border-radius: 999px;
            border: 1px solid rgba(148,163,184,.7);
            background: rgba(15,23,42,.9);
            color: #e5e7eb;
            display: inline-flex;
            align-items: center;
            gap: .4rem;
        }

        .lp-pill-dot {
            width: 6px;
            height: 6px;
            border-radius: 999px;
            background: #22c55e;
            box-shadow: 0 0 10px rgba(34,197,94,.9);
        }

        .lp-header-main {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 14px;
            flex-wrap: wrap;
            margin-bottom: 18px;
        }

        .lp-header-main h1 {
            margin: 0;
            font-size: 1.8rem;
            font-weight: 800;
        }

        .lp-header-main p {
            margin: 4px 0 0 0;
            font-size: 0.88rem;
            color: rgba(226,232,240,.78);
        }

        .lp-header-meta {
            text-align: right;
            font-size: 0.8rem;
            color: rgba(148,163,184,.9);
        }

        .lp-header-meta strong {
            font-size: 1.2rem;
            color: #e5e7eb;
        }

        /* Tarjeta de resumen arriba de la grilla */
        .lp-summary {
            margin-top: 14px;
            margin-bottom: 12px;
            padding: 10px 14px;
            border-radius: 16px;
            background: radial-gradient(circle at top left, rgba(56,189,248,.14), rgba(15,23,42,.96));
            border: 1px solid rgba(148,163,184,.5);
            box-shadow: 0 15px 40px rgba(0,0,0,.7);
            display: flex;
            justify-content: space-between;
            gap: 10px;
            align-items: center;
            font-size: 0.8rem;
        }

        .lp-summary span.label {
            text-transform: uppercase;
            letter-spacing: .18em;
            font-size: .7rem;
            color: rgba(209,213,219,.9);
        }

        .lp-summary span.value {
            font-weight: 700;
            margin-left: 6px;
        }

        .lp-summary-right {
            text-align: right;
            color: rgba(148,163,184,.9);
        }

        /* Grilla de tarjetas */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 18px;
            margin-top: 16px;
        }

        /* enlace que envuelve la card */
        .client-link{
            text-decoration:none;
            color:inherit;
        }

        .client-card {
            background: rgba(15,23,42,0.98);
            border: 1px solid rgba(148,163,184,0.4);
            border-radius: 16px;
            padding: 14px 14px 13px;
            box-shadow: 0 18px 40px rgba(0,0,0,0.7);
            display: flex;
            flex-direction: column;
            gap: 8px;
            transition: transform .15s ease, box-shadow .15s ease, border-color .15s ease;
            cursor: pointer;
        }

        .client-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 24px 55px rgba(0,0,0,0.9);
            border-color: rgba(56,189,248,.85);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            margin-bottom: 4px;
        }

        .card-name-block {
            display: flex;
            align-items: center;
            gap: 8px;
            min-width: 0;
        }

        .avatar {
            width: 32px;
            height: 32px;
            border-radius: 999px;
            background: radial-gradient(circle at top, #38bdf8, #0f172a);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            font-weight: 700;
            color: #e5e7eb;
            flex-shrink: 0;
        }

        .client-name {
            font-weight: 700;
            font-size: 0.98rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .badge {
            background: linear-gradient(135deg,#4f46e5,#06b6d4);
            color: #f9fafb;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 0.7rem;
            font-weight: 600;
            letter-spacing: 0.16em;
            text-transform: uppercase;
            white-space: nowrap;
        }

        .card-body p {
            margin: 3px 0;
            font-size: 0.86rem;
            color: #e8eef7;
        }

        .label {
            font-weight: 600;
            color: rgba(209,213,219,.95);
        }

        .small {
            font-size: 0.8rem;
            color: rgba(148,163,184,0.8);
        }

        .empty-state {
            margin-top: 22px;
            padding: 18px 16px;
            border-radius: 18px;
            border: 1px dashed rgba(148,163,184,.6);
            background: rgba(15,23,42,.9);
            font-size: 0.9rem;
            color: rgba(209,213,219,.9);
        }
    </style>
</head>

<body class="text-white">
    <%@ include file="../Includes/nav_base_administrador.jspf" %>

    <main class="lp-page">
        <!-- Encabezado -->
        <section class="lp-header-main">
            <div>
                <div class="lp-pill">
                    <span class="lp-pill-dot"></span>
                    Listado · Clientes
                </div>
                <h1>Clientes</h1>
                <p>Usuarios registrados con rol <strong>CLIENTE</strong> dentro de la plataforma.</p>
            </div>

            <div class="lp-header-meta">
                <div><span class="small">Total clientes</span></div>
                <div><strong><%= totalClientes %></strong></div>
            </div>
        </section>

        <!-- Resumen -->
        <section class="lp-summary">
            <div>
                <span class="label">Clientes activos:</span>
                <span class="value"><%= totalClientes %></span>
            </div>
            <div class="lp-summary-right">
                <div>Este listado es de solo lectura para revisar datos de contacto rápidos.</div>
                <div>Desde aquí puedes validar email y teléfono antes de contactar al cliente.</div>
            </div>
        </section>

        <!-- Listado de clientes -->
        <section>
            <% if (clientes != null && !clientes.isEmpty()) { %>
                <div class="cards-grid">
                    <% for (User u : clientes) {
                        String nombre = (u.getName() != null) ? u.getName().trim() : "Sin nombre";
                        String iniciales = "";
                        if (!nombre.isEmpty()) {
                            String[] partes = nombre.split(" ");
                            if (partes.length == 1) {
                                iniciales = partes[0].substring(0,1).toUpperCase();
                            } else {
                                iniciales = (partes[0].substring(0,1) + partes[partes.length-1].substring(0,1)).toUpperCase();
                            }
                        }
                    %>
                        <!-- Card clickeable: lleva al perfil -->
                        <a href="PerfilCliente.jsp?id=<%= u.getId() %>" class="client-link">
                            <div class="client-card">
                                <div class="card-header">
                                    <div class="card-name-block">
                                        <div class="avatar"><%= iniciales %></div>
                                        <div class="client-name" title="<%= nombre %>"><%= nombre %></div>
                                    </div>
                                    <span class="badge">CLIENTE</span>
                                </div>

                                <div class="card-body">
                                    <p><span class="label">ID:</span> <%= u.getId() %></p>
                                    <p><span class="label">Email:</span> <%= u.getEmail() != null ? u.getEmail() : "-" %></p>
                                    <p><span class="label">Tel:</span> <%= u.getPhone() != null ? u.getPhone() : "-" %></p>
                                </div>

                                <div class="small">
                                    Clic para ver perfil completo, tickets y actividad.
                                </div>
                            </div>
                        </a>
                    <% } %>
                </div>
            <% } else { %>
                <div class="empty-state">
                    No se encontraron clientes registrados con rol <strong>CLIENTE</strong>.
                    Cuando nuevos usuarios se registren en la plataforma, aparecerán listados aquí.
                </div>
            <% } %>
        </section>
    </main>
</body>
</html>
