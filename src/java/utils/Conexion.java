package utils;

import java.sql.*;
import java.util.ArrayList;

/**
 * Conexion MySQL adaptada al proyecto:
 * - Driver MySQL 9 (com.mysql.cj.jdbc.Driver)
 * - UTF-8, TZ America/Bogota
 * - Sin SSL y con allowPublicKeyRetrieval (para XAMPP/WAMP)
 *
 * Mantiene las mismas firmas de métodos que tu versión original
 * (insertar, actualizar, consultaFila, consultarRegistrosActivos, consultaMatriz, contar, sumar).
 */
public class Conexion {

    private Connection conn; // Conexión viva para operaciones estilo "abrir/usar/cerrar"
    private String mensaje;

    // === Config DB (ajusta a tu entorno) ===
    private String BD_NAME   = "livepass";     // <-- cámbialo a "comerciobuga" si tu BD se llama así
    private String USER      = "root";
    private String PASS      = "";
    private String HOST      = "127.0.0.1";
    private String PORT      = "3306";

    // === Getters/Setters útiles para parametrizar desde fuera si quieres ===
    public void setDbName(String db) { this.BD_NAME = db; }
    public void setUser(String u)    { this.USER = u; }
    public void setPass(String p)    { this.PASS = p; }
    public void setHost(String h)    { this.HOST = h; }
    public void setPort(String p)    { this.PORT = p; }

    public Conexion() {
        this.conn = null;
        this.mensaje = "";
    }

    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }

    // URL moderna con parámetros recomendados para MySQL 8
    private String jdbcUrl() {
        return "jdbc:mysql://" + HOST + ":" + PORT + "/" + BD_NAME
             + "?allowPublicKeyRetrieval=true"
             + "&useSSL=false"
             + "&useUnicode=true"
             + "&characterEncoding=UTF-8"
             + "&serverTimezone=America/Bogota";
    }

    /**
     * Abre la conexión (si no está abierta). Retorna true si queda conectada.
     */
    public boolean conectarMySQL() {
        try {
            System.out.println("[Conexion] Cargando driver MySQL...");
            Class.forName("com.mysql.cj.jdbc.Driver");

            if (this.conn == null || this.conn.isClosed()) {
                String url = jdbcUrl();
                System.out.println("[Conexion] Conectando: " + url);
                this.conn = DriverManager.getConnection(url, USER, PASS);
            }

            this.mensaje = "Conexión exitosa a la base de datos.";
            System.out.println("[Conexion] Conexión establecida a " + BD_NAME);
            return true;

        } catch (ClassNotFoundException e) {
            this.mensaje = "No se encuentra el driver MySQL: " + e.getMessage();
            e.printStackTrace();
            return false;

        } catch (SQLException ex) {
            this.mensaje = "No se pudo conectar a '" + BD_NAME + "': " + ex.getMessage();
            ex.printStackTrace();
            return false;
        }
    }

    /**
     * Verifica la conexión y, si está cerrada, intenta reconectar.
     */
    public boolean estaConectado() {
        try {
            if (conn != null && !conn.isClosed()) {
                return true;
            }
            return conectarMySQL();
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    public Connection getConnection() {
    // asegura que la conexión esté abierta
    if (!estaConectado()) return null; 
    return conn;
    }

    /**
     * Devuelve una Connection válida (y se asegura de conectarla si hace falta).
     * Útil si quieres usar esta clase como "factory" desde DAOs específicos.
     */
    /*public Connection getConnection() throws SQLException {
        if (!estaConectado()) {
            throw new SQLException("No hay conexión a MySQL: " + getMensaje());
        }
        return this.conn;
    }*/

    /**
     * Cierra la conexión viva.
     */
    
    public static Connection getConexion() {
    try {
        Conexion c = new Conexion();
        if (!c.estaConectado()) {
            System.out.println("No fue posible conectar a la base de datos.");
            return null;
        }
        return c.getConnection();
        } catch (Exception e) {
            System.out.println("Error al obtener conexión: " + e.getMessage());
            return null;
        }
    }
    
    public void cerrarConexion() {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
                System.out.println("[Conexion] Conexión cerrada.");
            }
        } catch (SQLException e) {
            System.err.println("[Conexion] Error al cerrar: " + e.getMessage());
        } finally {
            conn = null;
        }
    }

    // ==========================
    //  Métodos genéricos (compat)
    // ==========================

    public boolean insertar(String tabla, ArrayList<String> columnNames, ArrayList<Object> values) {
        PreparedStatement ps = null;
        try {
            if (!estaConectado()) return false;

            StringBuilder cols = new StringBuilder("(");
            for (int i = 0; i < columnNames.size(); i++) {
                cols.append(columnNames.get(i));
                if (i < columnNames.size() - 1) cols.append(", ");
            }
            cols.append(")");

            StringBuilder vals = new StringBuilder("VALUES (");
            for (int i = 0; i < values.size(); i++) {
                vals.append("?");
                if (i < values.size() - 1) vals.append(", ");
            }
            vals.append(")");

            String sql = "INSERT INTO " + tabla + " " + cols + " " + vals;
            System.out.println("[Conexion][INSERT] " + sql);

            ps = conn.prepareStatement(sql);
            for (int i = 0; i < values.size(); i++) ps.setObject(i + 1, values.get(i));

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            this.mensaje = "Error INSERT en '" + tabla + "': " + e.getMessage();
            e.printStackTrace();
            return false;

        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
            cerrarConexion();
        }
    }

    public boolean actualizar(String tabla, ArrayList<String> columnNames, ArrayList<Object> values,
                              String condicionSQLTemplate, ArrayList<Object> condicionParams) {
        PreparedStatement ps = null;
        try {
            if (!estaConectado()) return false;

            StringBuilder sb = new StringBuilder("UPDATE ").append(tabla).append(" SET ");
            for (int i = 0; i < columnNames.size(); i++) {
                sb.append(columnNames.get(i)).append("=?");
                if (i < columnNames.size() - 1) sb.append(", ");
            }
            if (condicionSQLTemplate != null && !condicionSQLTemplate.trim().isEmpty()) {
                sb.append(" WHERE ").append(condicionSQLTemplate);
            }
            String sql = sb.append(";").toString();
            System.out.println("[Conexion][UPDATE] " + sql);

            ps = conn.prepareStatement(sql);

            int idx = 1;
            for (Object v : values) ps.setObject(idx++, v);
            if (condicionParams != null) for (Object p : condicionParams) ps.setObject(idx++, p);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            this.mensaje = "Error UPDATE en '" + tabla + "': " + e.getMessage();
            e.printStackTrace();
            return false;

        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
            cerrarConexion();
        }
    }

    public String[] consultaFila(String tabla, String columnaCondicion, String valorCondicion) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            if (!estaConectado()) return null;

            String sql = "SELECT * FROM " + tabla + " WHERE " + columnaCondicion + " = ?;";
            System.out.println("[Conexion][SELECT 1] " + sql);

            ps = conn.prepareStatement(sql);
            ps.setString(1, valorCondicion);
            rs = ps.executeQuery();

            if (!rs.next()) {
                mensaje = "Sin resultados en '" + tabla + "'.";
                return null;
            }
            ResultSetMetaData md = rs.getMetaData();
            int cols = md.getColumnCount();
            String[] fila = new String[cols];
            for (int i = 1; i <= cols; i++) fila[i - 1] = rs.getString(i);
            return fila;

        } catch (SQLException e) {
            this.mensaje = "Error SELECT 1 en '" + tabla + "': " + e.getMessage();
            e.printStackTrace();
            return null;

        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
            cerrarConexion();
        }
    }

    public ArrayList<String[]> consultarRegistrosActivos(String tabla) {
        ArrayList<String[]> out = new ArrayList<>();
        String sql = "SELECT * FROM " + tabla + " WHERE estado = 1;";
        PreparedStatement ps = null; ResultSet rs = null;
        try {
            if (!estaConectado()) return out;

            System.out.println("[Conexion][SELECT activos] " + sql);
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            ResultSetMetaData md = rs.getMetaData();
            int cols = md.getColumnCount();

            while (rs.next()) {
                String[] fila = new String[cols];
                for (int i = 1; i <= cols; i++) fila[i - 1] = rs.getString(i);
                out.add(fila);
            }
            this.mensaje = "OK (" + out.size() + " filas)";
            return out;

        } catch (SQLException e) {
            this.mensaje = "Error SELECT activos en '" + tabla + "': " + e.getMessage();
            e.printStackTrace();
            return out;

        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
            cerrarConexion();
        }
    }

    public String[][] consultaMatriz(String sql, ArrayList<Object> params) {
        PreparedStatement ps = null; ResultSet rs = null;
        try {
            if (!estaConectado()) return null;

            System.out.println("[Conexion][QUERY matriz] " + sql);
            ps = conn.prepareStatement(sql, ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY);

            if (params != null) for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));

            rs = ps.executeQuery();

            int rows = 0;
            if (rs.last()) { rows = rs.getRow(); rs.beforeFirst(); }
            if (rows == 0) { mensaje = "Sin resultados"; return null; }

            int cols = rs.getMetaData().getColumnCount();
            String[][] data = new String[rows][cols];
            int r = 0;
            while (rs.next()) {
                for (int c = 0; c < cols; c++) data[r][c] = rs.getString(c + 1);
                r++;
            }
            return data;

        } catch (SQLException e) {
            this.mensaje = "Error QUERY matriz: " + e.getMessage();
            e.printStackTrace();
            return null;

        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
            cerrarConexion();
        }
    }

    public int contar(String tabla, String condicionSQL, ArrayList<Object> params) {
        PreparedStatement ps = null; ResultSet rs = null;
        try {
            if (!estaConectado()) return -1;

            String sql = "SELECT COUNT(*) FROM " + tabla + (condicionSQL!=null && !condicionSQL.isBlank() ? " WHERE " + condicionSQL : "");
            System.out.println("[Conexion][COUNT] " + sql);

            ps = conn.prepareStatement(sql);
            if (params != null) for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));

            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;

        } catch (SQLException e) {
            this.mensaje = "Error COUNT en '" + tabla + "': " + e.getMessage();
            e.printStackTrace();
            return -1;

        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
            cerrarConexion();
        }
    }

    public double sumar(String tabla, String campo, String condicionSQL, ArrayList<Object> params) {
        PreparedStatement ps = null; ResultSet rs = null;
        try {
            if (!estaConectado()) return -1;

            String sql = "SELECT SUM(" + campo + ") FROM " + tabla + (condicionSQL!=null && !condicionSQL.isBlank() ? " WHERE " + condicionSQL : "");
            System.out.println("[Conexion][SUM] " + sql);

            ps = conn.prepareStatement(sql);
            if (params != null) for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));

            rs = ps.executeQuery();
            return rs.next() ? rs.getDouble(1) : 0.0;

        } catch (SQLException e) {
            this.mensaje = "Error SUM en '" + tabla + "': " + e.getMessage();
            e.printStackTrace();
            return -1;

        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
            cerrarConexion();
        }
    }
}
