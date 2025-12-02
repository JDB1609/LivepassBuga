<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String loginErr = (String) request.getAttribute("login_error");
    String fEmail   = (String) request.getAttribute("f_email");
%>
<!DOCTYPE html>
<html lang="es">

<head>
    <%@ include file="../Includes/head_base.jspf" %>
    <title>Login Administrador — Livepass Buga</title>

    <!-- Estilos adicionales -->
    <style>
        body {
            background: url('../Imagenes/Staff.jpg') no-repeat center center fixed;
            background-size: cover;
            backdrop-filter: blur(5px);
        }

        .login-card {
            background: rgba(0, 0, 0, 0.55);
            backdrop-filter: blur(12px);
            box-shadow: 0 0 40px rgba(0, 0, 0, 0.5);
        }

        .input-style {
            background: rgba(255, 255, 255, 0.12);
            border: 1px solid rgba(255, 255, 255, 0.25);
        }

        .input-style:focus {
            border-color: #00d2d3;
            background: rgba(255, 255, 255, 0.18);
        }

        .btn-login {
            background: #00d2d3;
            transition: 0.2s;
        }

        .btn-login:hover {
            background: #00e0e0;
        }

        .logo-text {
            font-weight: 800;
            font-size: 2.5rem;
        }

        .brand-color {
            color: #5f27cd;
        }
    </style>
</head>

<body class="text-white min-h-screen flex items-center justify-center">

    <!-- CONTENEDOR CENTRAL -->
    <div class="w-full max-w-md px-6 py-10 rounded-2xl login-card">

        <!-- LOGO -->
        <div class="text-center mb-6">
            <span class="logo-text">
                <span class="brand-color">LivePass</span>Buga
            </span>
        </div>

        <!-- Mensaje error -->
        <% if (loginErr != null) { %>
            <div class="mb-4 p-3 rounded-lg bg-red-700/40 border border-red-500">
                <%= loginErr %>
            </div>
        <% } %>

        <!-- FORMULARIO -->
        <form action="<%= request.getContextPath() %>/Control/ct_login_admin.jsp"
              method="post" class="space-y-5" accept-charset="UTF-8">

            <!-- Email -->
            <div>
                <input type="email"
                       name="email"
                       placeholder="Correo electrónico"
                       required
                       value="<%= fEmail != null ? fEmail : "" %>"
                       class="w-full px-4 py-3 rounded-lg input-style focus:outline-none" />
            </div>

            <!-- Contraseña -->
            <div>
                <input type="password"
                       name="pass"
                       placeholder="Contraseña"
                       required
                       class="w-full px-4 py-3 rounded-lg input-style focus:outline-none" />
            </div>

            <!-- Botón -->
            <button type="submit"
                    class="w-full py-3 rounded-lg text-black font-semibold btn-login">
                Entrar
            </button>

        </form>

        <p class="text-center text-white/70 mt-5 text-sm">
            Acceso exclusivo para administradores.
        </p>

    </div>

</body>

</html>