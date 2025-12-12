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
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base_administrador.jspf" %>
    <title>Clientes — Livepass Buga</title>

    <style>
        body {
            background: #0b1020;
            color: #fff;
            font-family: inter, system-ui, sans-serif;
        }

        .container {
            max-width: 1100px;
            margin: 36px auto;
            padding: 20px;
        }

        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 18px;
        }

        .client-card {
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 14px;
            padding: 16px;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            font-weight: 800;
            margin-bottom: 10px;
        }

        .badge {
            background: #00d1b2;
            color: #003;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 0.8rem;
        }

        .card-body p {
            margin: 6px 0;
            font-size: 0.92rem;
            color: #e8eef7;
        }

        .small {
            font-size: 0.9rem;
            color: rgba(255, 255, 255, 0.7);
        }
    </style>
</head>

<body class="text-white">
    <%@ include file="../Includes/nav_base_administrador.jspf" %>

    <div class="container">
        <div style="
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 14px;
            flex-wrap: wrap;
        ">
            <div>
                <h1 style="margin: 0">Clientes</h1>
                <div class="small">
                    Usuarios registrados con rol CLIENTE
                </div>
            </div>
        </div>

        <div class="cards-grid">
            <% for (User u : clientes) { %>
                <div class="client-card">
                    <div class="card-header">
                        <strong><%= u.getName() %></strong>
                        <span class="badge">CLIENTE</span>
                    </div>

                    <div class="card-body">
                        <p><b>ID:</b> <%= u.getId() %></p>
                        <p><b>Email:</b> <%= u.getEmail() %></p>
                        <p><b>Tel:</b> <%= u.getPhone() %></p>
                    </div>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>