<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, utils.Event, dao.EventDAO" %>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/Vista/LoginAdmin.jsp");
        return;
    }

    List<Event> eventos = null;
    try {
        EventDAO dao = new EventDAO();
        eventos = dao.listAllEvents();   // 👈 NUEVO MÉTODO
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base_administrador.jspf" %>
    <title>Eventos — Livepass Buga</title>

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

        .event-card {
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

        .badge-publicado { background: #2ecc71; color: #021; }
        .badge-borrador  { background: #f1c40f; color: #000; }
        .badge-finalizado{ background: #3498db; color: #fff; }
        .badge-cancelado { background: #e74c3c; color: #fff; }

        .card-body p {
            margin: 6px 0;
            font-size: 0.92rem;
            color: #e8eef7;
        }

        .small {
            font-size: 0.9rem;
            color: rgba(255, 255, 255, 0.7);
        }

        .price {
            font-weight: 700;
            color: #00d1b2;
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
                <h1 style="margin: 0">Eventos</h1>
                <div class="small">
                    Todos los eventos del sistema
                </div>
            </div>
        </div>

        <div class="cards-grid">
            <% for (Event e : eventos) { %>

                <div class="event-card">
                    <div class="card-header">
                        <strong><%= e.getTitle() %></strong>

                        <span class="badge
                            <%= e.isPublicado() ? "badge-publicado" :
                                e.isBorrador() ? "badge-borrador" :
                                e.isFinalizado() ? "badge-finalizado" :
                                "badge-cancelado" %>">

                            <%= e.getStatus() %>
                        </span>
                    </div>

                    <div class="card-body">
                        <p><b>ID:</b> <%= e.getId() %></p>
                        <p><b>Ciudad:</b> <%= e.getCity() %></p>
                        <p><b>Lugar:</b> <%= e.getVenue() %></p>
                        <p><b>Fecha:</b> <%= e.getDate() %></p>
                        <p><b>Tipo:</b> <%= e.getEventType() %></p>
                        <p><b>Género:</b> <%= e.getGenre() %></p>

                        <p>
                            <b>Precio base:</b>
                            <span class="price"><%= e.getPriceFormatted() %></span>
                        </p>

                        <p>
                            <b>Aforo:</b> <%= e.getCapacity() %> |
                            <b>Vendidos:</b> <%= e.getSold() %> |
                            <b>Disponibles:</b> <%= e.getAvailability() %>
                        </p>
                    </div>
                </div>

            <% } %>
        </div>
    </div>
</body>
</html>