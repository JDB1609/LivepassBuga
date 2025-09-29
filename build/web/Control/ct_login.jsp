<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.UserDAO,utils.User" %>
<%
  request.setCharacterEncoding("UTF-8");
  String email = request.getParameter("email");
  String pass  = request.getParameter("pass");

  if (email==null || pass==null) {
    request.setAttribute("login_error","Completa tus credenciales.");
    request.getRequestDispatcher("../Vista/Login.jsp").forward(request,response);
    return;
  }

  try {
    UserDAO dao = new UserDAO();
    java.util.Optional<utils.User> opt = dao.auth(email.trim(), pass);
    if (opt.isEmpty()) {
      request.setAttribute("login_error","Correo o contraseña incorrectos.");
      request.setAttribute("f_email", email);
      request.getRequestDispatcher("../Vista/Login.jsp").forward(request,response);
      return;
    }
    utils.User u = opt.get();
    session.setAttribute("userId",   u.getId());
    session.setAttribute("userName", u.getName());
    session.setAttribute("userEmail",u.getEmail());
    session.setAttribute("role",     u.getRole());

    // Redirige según rol
    String ctx = request.getContextPath();
    if ("ORGANIZADOR".equalsIgnoreCase(u.getRole())) {
      response.sendRedirect(ctx + "/Vista/DashboardOrganizador.jsp");
    } else {
      response.sendRedirect(ctx + "/Vista/HomeCliente.jsp");
    }
  } catch (Exception ex) {
    request.setAttribute("login_error","Error al iniciar sesión: " + ex.getMessage());
    request.setAttribute("f_email", email);
    request.getRequestDispatcher("../Vista/Login.jsp").forward(request,response);
  }
%>
