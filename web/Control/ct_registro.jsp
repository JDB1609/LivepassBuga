<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="dao.UserDAO" %>
<%
  request.setCharacterEncoding("UTF-8");

  String nombre = request.getParameter("nombre");
  String email  = request.getParameter("email");
  String tel    = request.getParameter("telefono");
  String role   = request.getParameter("role");
  String pass   = request.getParameter("pass");
  String pass2  = request.getParameter("pass2");

  Map<String,String> errors = new HashMap<>();

  if (nombre==null || nombre.trim().length()<3) errors.put("nombre","Ingresa tu nombre completo");
  if (email==null || !email.contains("@")) errors.put("email","Email no válido");
  if (role==null || (!role.equalsIgnoreCase("CLIENTE") && !role.equalsIgnoreCase("ORGANIZADOR")))
      errors.put("role","Selecciona un tipo de cuenta");
  if (pass==null || pass.length()<8) errors.put("pass","Mínimo 8 caracteres");
  if (pass2==null || !pass2.equals(pass)) errors.put("pass2","Las contraseñas no coinciden");

  // Si hay errores => volver a la vista con los datos
  if (!errors.isEmpty()) {
    request.setAttribute("errors", errors);
    request.setAttribute("f_nombre", nombre);
    request.setAttribute("f_email", email);
    request.setAttribute("f_tel", tel);
    request.setAttribute("f_role", role);
    request.getRequestDispatcher("../Vista/Registro.jsp").forward(request, response);
    return;
  }

  try {
    UserDAO dao = new UserDAO();
    if (dao.emailExists(email)) {
      errors.put("email","Ya existe una cuenta con este correo");
      request.setAttribute("errors", errors);
      request.setAttribute("f_nombre", nombre);
      request.setAttribute("f_email", email);
      request.setAttribute("f_tel", tel);
      request.setAttribute("f_role", role);
      request.getRequestDispatcher("../Vista/Registro.jsp").forward(request, response);
      return;
    }

    int uid = dao.create(nombre.trim(), email.trim(), tel, role, pass);
    // Post/Redirect/Get
    response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp?ok=1");
  } catch (Exception ex) {
    errors.put("global","Error al registrar: "+ex.getMessage());
    request.setAttribute("errors", errors);
    request.setAttribute("f_nombre", nombre);
    request.setAttribute("f_email", email);
    request.setAttribute("f_tel", tel);
    request.setAttribute("f_role", role);
    request.getRequestDispatcher("../Vista/Registro.jsp").forward(request, response);
  }
%>
