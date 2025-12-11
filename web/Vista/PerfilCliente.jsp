<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="utils.User, utils.Ticket" %>
<%@ page import="dao.UserDAO, dao.TicketDAO" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    // ==========================
    // SEGURIDAD: SOLO ADMIN
    // ==========================
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/Vista/LoginAdmin.jsp");
        return;
    }

    // ==========================
    // OBTENER ID DE CLIENTE
    // ==========================
    String idParam = request.getParameter("id");
    if (idParam == null) {
        response.sendRedirect("ListarTodosClientes.jsp");
        return;
    }

    int userId = -1;
    try {
        userId = Integer.parseInt(idParam);
    } catch (NumberFormatException e) {
        response.sendRedirect("ListarTodosClientes.jsp");
        return;
    }

    // ==========================
    // CARGAR CLIENTE
    // (usamos listAllClients para evitar depender
    // de un método findById que quizá no exista)
    // ==========================
    UserDAO userDAO = new UserDAO();
    User cliente = null;
    try {
        List<User> all = userDAO.listAllClients();
        if (all != null) {
            for (User u : all) {
                if (u.getId() == userId) {
                    cliente = u;
                    break;
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (cliente == null) {
        response.sendRedirect("ListarTodosClientes.jsp");
        return;
    }

    // ==========================
    // CARGAR TICKETS DEL CLIENTE
    // (ajusta el método si en tu TicketDAO
    // se llama distinto)
    // ==========================
    TicketDAO ticketDAO = new TicketDAO();
    List<Ticket> tickets = null;
    try {
        tickets = ticketDAO.listByUser(userId); // <-- SI NO EXISTE, LUEGO TE DOY EL MÉTODO
    } catch (Exception e) {
        e.printStackTrace();
    }

    int totalTickets = (tickets != null) ? tickets.size() : 0;

    DateTimeFormatter FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base_administrador.jspf" %>
    <title>Perfil cliente — <%= (cliente.getName() != null ? cliente.getName() : "Cliente") %> | LivePassBuga</title>

    <style>
        body {
            background:#050816;
            color:#f9fafb;
            font-family:system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }

        .page {
            max-width:1100px;
            margin:34px auto 40px auto;
            padding:0 18px;
        }

        .pill {
            font-size:0.68rem;
            text-transform:uppercase;
            letter-spacing:0.22em;
            padding:0.18rem 0.8rem;
            border-radius:999px;
            border:1px solid rgba(148,163,184,.7);
            background:rgba(15,23,42,.9);
            color:#e5e7eb;
            display:inline-flex;
            align-items:center;
            gap:.4rem;
        }
        .pill-dot {
            width:6px;
            height:6px;
            border-radius:999px;
            background:#38bdf8;
            box-shadow:0 0 10px rgba(56,189,248,.9);
        }

        .header {
            display:flex;
            justify-content:space-between;
            align-items:flex-end;
            gap:18px;
            flex-wrap:wrap;
            margin-bottom:20px;
        }

        .perfil-main {
            display:flex;
            align-items:center;
            gap:14px;
            margin-top:10px;
        }

        .avatar-big {
            width:70px;
            height:70px;
            border-radius:999px;
            background:linear-gradient(135deg,#4f46e5,#06b6d4);
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:2rem;
            font-weight:800;
            color:#e5e7eb;
            box-shadow:0 18px 40px rgba(0,0,0,.7);
            flex-shrink:0;
        }

        .header h1 {
            margin:0;
            font-size:1.8rem;
            font-weight:800;
        }

        .header-sub {
            margin-top:4px;
            font-size:.9rem;
            color:rgba(148,163,184,.9);
        }

        .btn-volver {
            padding:9px 16px;
            border-radius:999px;
            background:rgba(15,23,42,1);
            border:1px solid rgba(148,163,184,.6);
            font-size:.8rem;
            color:#e5e7eb;
            text-decoration:none;
            display:inline-flex;
            align-items:center;
            gap:.35rem;
            transition:.18s;
        }
        .btn-volver:hover {
            border-color:#e5e7eb;
            background:#020617;
        }

        .card {
            background:rgba(15,23,42,.98);
            border-radius:18px;
            border:1px solid rgba(148,163,184,.45);
            padding:16px 16px 14px;
            margin-bottom:18px;
            box-shadow:0 18px 45px rgba(0,0,0,.75);
        }

        .card-title {
            font-size:1.05rem;
            font-weight:700;
            margin-bottom:8px;
        }

        .card-sub {
            font-size:.8rem;
            color:rgba(148,163,184,.9);
            margin-bottom:8px;
        }

        .grid-2 {
            display:grid;
            grid-template-columns:repeat(auto-fit,minmax(220px,1fr));
            gap:12px 24px;
            font-size:.9rem;
        }

        .label {
            font-weight:600;
            color:rgba(209,213,219,.95);
        }

        .value {
            color:#e5e7eb;
        }

        .summary-row {
            display:flex;
            gap:16px;
            flex-wrap:wrap;
            margin-top:10px;
        }
        .summary-pill {
            padding:6px 10px;
            border-radius:999px;
            border:1px solid rgba(148,163,184,.7);
            font-size:.78rem;
            color:rgba(209,213,219,.95);
        }

        table {
            width:100%;
            border-collapse:collapse;
            margin-top:8px;
        }
        th, td {
            padding:8px 6px;
            border-bottom:1px solid rgba(51,65,85,.8);
            font-size:.82rem;
        }
        th {
            text-align:left;
            text-transform:uppercase;
            letter-spacing:.14em;
            font-size:.72rem;
            color:rgba(148,163,184,.9);
        }
        tr:last-child td {
            border-bottom:none;
        }

        .chip-status {
            padding:3px 9px;
            border-radius:999px;
            font-size:.72rem;
            text-transform:uppercase;
            letter-spacing:.08em;
        }
        .chip-status.ACTIVO { background:rgba(34,197,94,.16); color:#bbf7d0; border:1px solid rgba(34,197,94,.6); }
        .chip-status.USADO  { background:rgba(59,130,246,.16); color:#bfdbfe; border:1px solid rgba(59,130,246,.6); }
        .chip-status.REEMBOLSADO { background:rgba(239,68,68,.16); color:#fecaca; border:1px solid rgba(239,68,68,.6); }

        .link-detalle {
            color:#38bdf8;
            text-decoration:none;
            font-size:.8rem;
        }
        .link-detalle:hover { text-decoration:underline; }

        .empty {
            font-size:.85rem;
            color:rgba(148,163,184,.9);
            margin-top:4px;
        }
    </style>
</head>

<body>
    <%@ include file="../Includes/nav_base_administrador.jspf" %>

    <main class="page">
        <%
            String nombre = (cliente.getName() != null) ? cliente.getName().trim() : "Cliente";
            String iniciales = "";
            if (!nombre.isEmpty()) {
                String[] partesNombre = nombre.split(" ");
                if (partesNombre.length == 1) {
                    iniciales = partesNombre[0].substring(0,1).toUpperCase();
                } else {
                    iniciales = (partesNombre[0].substring(0,1) + partesNombre[partesNombre.length-1].substring(0,1)).toUpperCase();
                }
            }
        %>

        <!-- ENCABEZADO PERFIL -->
        <section class="header">
            <div>
                <div class="pill">
                    <span class="pill-dot"></span>
                    Perfil · Cliente
                </div>

                <div class="perfil-main">
                    <div class="avatar-big"><%= iniciales %></div>
                    <div>
                        <h1><%= nombre %></h1>
                        <div class="header-sub">
                            ID Cliente: <strong><%= cliente.getId() %></strong> · Rol: CLIENTE
                        </div>
                    </div>
                </div>
            </div>

            <div>
                <a href="ListarTodosClientes.jsp" class="btn-volver">« Volver al listado</a>
            </div>
        </section>

        <!-- CARD: INFORMACIÓN PRINCIPAL -->
        <section class="card">
            <div class="card-title">Información del cliente</div>
            <div class="card-sub">Datos básicos registrados en LivePassBuga.</div>

            <div class="grid-2">
                <div>
                    <span class="label">Nombre completo</span><br>
                    <span class="value"><%= nombre %></span>
                </div>
                <div>
                    <span class="label">Correo electrónico</span><br>
                    <span class="value"><%= cliente.getEmail() != null ? cliente.getEmail() : "-" %></span>
                </div>
                <div>
                    <span class="label">Teléfono</span><br>
                    <span class="value"><%= cliente.getPhone() != null ? cliente.getPhone() : "No registrado" %></span>
                </div>
                <div>
                    <span class="label">Observaciones</span><br>
                    <span class="value">Cliente de LivePassBuga registrado en la plataforma.</span>
                </div>
            </div>
        </section>

        <!-- CARD: TICKETS DEL CLIENTE -->
        <section class="card">
            <div class="card-title">Actividad de tickets</div>
            <div class="card-sub">Entradas asociadas a este cliente.</div>

            <div class="summary-row">
                <div class="summary-pill">
                    Total tickets comprados: <strong><%= totalTickets %></strong>
                </div>
            </div>

            <% if (tickets != null && !tickets.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>Evento</th>
                            <th>Fecha evento</th>
                            <th>Fecha compra</th>
                            <th>Estado</th>
                            <th>Detalle</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Ticket t : tickets) {
                               String status = (t.getStatus() != null) ? t.getStatus().toUpperCase() : "ACTIVO";
                        %>
                            <tr>
                                <td>
                                    <%= (t.getEventTitle() != null
                                         ? t.getEventTitle()
                                         : ("Evento #" + t.getEventId())) %>
                                </td>
                                <td>
                                    <% if (t.getEventDateTime() != null) { %>
                                        <%= t.getEventDateTime().format(FMT) %>
                                    <% } else { %>
                                        -
                                    <% } %>
                                </td>
                                <td>
                                    <% if (t.getPurchaseAt() != null) { %>
                                        <%= t.getPurchaseAt().format(FMT) %>
                                    <% } else { %>
                                        -
                                    <% } %>
                                </td>
                                <td>
                                    <span class="chip-status <%= status %>">
                                        <%= status %>
                                    </span>
                                </td>
                                <td>
                                    <a href="MisTicketsDetalleAdmin.jsp?id=<%= t.getId() %>" class="link-detalle">
                                        Ver ticket
                                    </a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <p class="empty">
                    Este cliente aún no tiene tickets asociados en la plataforma.
                </p>
            <% } %>
        </section>

    </main>
</body>
</html>
