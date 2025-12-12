<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, utils.Ticket, dao.TicketDAO" %>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/Vista/LoginAdmin.jsp");
        return;
    }

    List<Ticket> tickets = null;
    try {
        TicketDAO dao = new TicketDAO();
        tickets = dao.listAllTickets();   // 👈 NUEVO MÉTODO ADMIN
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base_administrador.jspf" %>
    <title>Tickets — Livepass Buga</title>

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
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 18px;
        }

        .ticket-card {
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
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 0.75rem;
            font-weight: 700;
        }

        .badge-activo { background: #2ecc71; color: #021; }
        .badge-usado  { background: #e67e22; color: #000; }

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
                <h1 style="margin: 0">Tickets</h1>
                <div class="small">
                    Todos los tickets vendidos en la plataforma
                </div>
            </div>
        </div>

        <div class="cards-grid">
            <% for (Ticket t : tickets) { %>

                <div class="ticket-card">

                    <div class="card-header">
                        <strong>Ticket #<%= t.getId() %></strong>

                        <span class="badge
                            <%= "USADO".equalsIgnoreCase(t.getStatus())
                                ? "badge-usado"
                                : "badge-activo" %>">

                            <%= t.getStatus() %>
                        </span>
                    </div>

                    <div class="card-body">
                        <p><b>Evento:</b> <%= t.getEventTitle() %></p>
                        <p><b>Lugar:</b> <%= t.getVenue() %></p>
                        <p><b>Fecha evento:</b> <%= t.getDate() %></p>

                        <p><b>ID Usuario:</b> <%= t.getUserId() %></p>
                        <p><b>ID Evento:</b> <%= t.getEventId() %></p>

                        <p><b>Fecha compra:</b>
                            <%= t.getPurchaseAt() != null ? t.getPurchaseAt() : "" %>
                        </p>

                        <% if (t.getQrCode() != null && !t.getQrCode().isEmpty()) { %>
                            <p><b>QR:</b> <%= t.getQrCode() %></p>
                        <% } %>
                    </div>

                </div>

            <% } %>
        </div>
    </div>
</body>
</html>