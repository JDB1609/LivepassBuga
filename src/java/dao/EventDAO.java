package dao;

import utils.Conexion;
import utils.Event;

import java.sql.*;
import java.util.*;
import java.math.BigDecimal;

public class EventDAO {

    /* ============ Mapper ============ */
    private Event map(ResultSet rs) throws SQLException {
        Event e = new Event();
        e.setId(rs.getInt("id"));

        try { e.setOrganizerId((Integer) rs.getObject("organizer_id")); } catch (SQLException ignore) {}

        e.setTitle(rs.getString("title"));
        e.setVenue(rs.getString("venue"));
        try { e.setGenre(rs.getString("genre")); } catch (SQLException ignore) {}
        try { e.setCity(rs.getString("city")); }  catch (SQLException ignore) {}

        Timestamp ts = null;
        try { ts = rs.getTimestamp("date_time"); } catch (SQLException ignore) {}
        if (ts != null) e.setDateTime(ts.toLocalDateTime());

        e.setCapacity(safeInt(rs, "capacity"));
        e.setSold(safeInt(rs, "sold"));

        try { e.setStatus(rs.getString("status")); } catch (SQLException ignore) {}

        try { e.setPrice(rs.getBigDecimal("price")); } catch (SQLException ignore) {}

        return e;
    }

    private int safeInt(ResultSet rs, String col) {
        try { return rs.getInt(col); } catch (SQLException e) { return 0; }
    }

    /* ============ Listas públicas / búsquedas ============ */

    /** Próximos publicados, ordenados por vendidos y fecha (para home) */
    public List<Event> listFeatured(int limit) {
        String sql = """
            SELECT * FROM events
            WHERE status='PUBLICADO' AND date_time >= NOW()
            ORDER BY sold DESC, date_time ASC
            LIMIT ?
        """;
        List<Event> out = new ArrayList<>();
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(1, limit));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(map(rs));
            }
        } catch (Exception e) { throw new RuntimeException(e); }
        return out;
    }

    /** Buscador de ExplorarEventos.jsp con filtros y paginación */
    public List<Event> search(String q, String genre, String city,
                              BigDecimal pmin, BigDecimal pmax,
                              String order, int page, int pageSize) {
        StringBuilder sb = new StringBuilder(
            "SELECT * FROM events WHERE status='PUBLICADO' AND date_time >= NOW()"
        );
        List<Object> p = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sb.append(" AND (title LIKE ? OR venue LIKE ?)");
            String like = "%" + q.trim() + "%";
            p.add(like); p.add(like);
        }
        if (genre != null && !genre.isBlank()) { sb.append(" AND genre = ?"); p.add(genre); }
        if (city  != null && !city.isBlank())  { sb.append(" AND city  = ?"); p.add(city); }
        if (pmin  != null) { sb.append(" AND price >= ?"); p.add(pmin); }
        if (pmax  != null) { sb.append(" AND price <= ?"); p.add(pmax); }

        sb.append(" ORDER BY ");
        if ("price_asc".equalsIgnoreCase(order)) sb.append("price ASC");
        else if ("price_desc".equalsIgnoreCase(order)) sb.append("price DESC");
        else sb.append("date_time ASC");

        sb.append(" LIMIT ? OFFSET ?");
        int offset = Math.max(0, (Math.max(1, page) - 1) * Math.max(1, pageSize));
        p.add(Math.max(1, pageSize));
        p.add(offset);

        List<Event> out = new ArrayList<>();
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {
            bind(ps, p);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(map(rs));
            }
        } catch (Exception e) { throw new RuntimeException(e); }
        return out;
    }

    /** Total para la paginación del buscador */
    public int countSearch(String q, String genre, String city,
                           BigDecimal pmin, BigDecimal pmax) {
        StringBuilder sb = new StringBuilder(
            "SELECT COUNT(*) FROM events WHERE status='PUBLICADO' AND date_time >= NOW()"
        );
        List<Object> p = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sb.append(" AND (title LIKE ? OR venue LIKE ?)");
            String like = "%" + q.trim() + "%";
            p.add(like); p.add(like);
        }
        if (genre != null && !genre.isBlank()) { sb.append(" AND genre = ?"); p.add(genre); }
        if (city  != null && !city.isBlank())  { sb.append(" AND city  = ?"); p.add(city); }
        if (pmin  != null) { sb.append(" AND price >= ?"); p.add(pmin); }
        if (pmax  != null) { sb.append(" AND price <= ?"); p.add(pmax); }

        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {
            bind(ps, p);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) { throw new RuntimeException(e); }
    }

    /** Distintos géneros (para selects) */
    public List<String> listGenres() {
        String sql = "SELECT DISTINCT genre FROM events WHERE genre IS NOT NULL AND genre<>'' ORDER BY genre";
        List<String> out = new ArrayList<>();
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(rs.getString(1));
        } catch (Exception e) { throw new RuntimeException(e); }
        return out;
    }

    /** Distintas ciudades (para selects) */
    public List<String> listCities() {
        String sql = "SELECT DISTINCT city FROM events WHERE city IS NOT NULL AND city<>'' ORDER BY city";
        List<String> out = new ArrayList<>();
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(rs.getString(1));
        } catch (Exception e) { throw new RuntimeException(e); }
        return out;
    }

    /* ============ CRUD organizador ============ */

    public List<Event> listByOrganizer(int organizerId, String q, String status) {
        StringBuilder sb = new StringBuilder("SELECT * FROM events WHERE organizer_id=?");
        List<Object> p = new ArrayList<>(); p.add(organizerId);

        if (status!=null && !status.isBlank()) { sb.append(" AND status=?"); p.add(status.toUpperCase()); }
        if (q!=null && !q.isBlank()) {
            sb.append(" AND (title LIKE ? OR venue LIKE ?)");
            String like = "%"+q.trim()+"%"; p.add(like); p.add(like);
        }
        sb.append(" ORDER BY date_time DESC");

        List<Event> out = new ArrayList<>();
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {
            bind(ps, p);
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) out.add(map(rs)); }
        } catch (Exception e) { throw new RuntimeException(e); }
        return out;
    }

    public Optional<Event> findById(int id) {
        String sql = "SELECT * FROM events WHERE id=?";
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }
        } catch (Exception e) { throw new RuntimeException(e); }
        return Optional.empty();
    }

    public int create(Event e) {
        String sql = """
            INSERT INTO events(organizer_id, title, venue, genre, city, date_time,
                               capacity, sold, status, price)
            VALUES(?,?,?,?,?,?,?,?,?,?)
        """;
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            if (e.getOrganizerId()!=null) ps.setInt(1, e.getOrganizerId());
            else ps.setNull(1, Types.INTEGER);

            ps.setString(2, e.getTitle());
            ps.setString(3, e.getVenue());
            ps.setString(4, e.getGenre());
            ps.setString(5, e.getCity());

            if (e.getDateTime()!=null) ps.setTimestamp(6, Timestamp.valueOf(e.getDateTime()));
            else ps.setNull(6, Types.TIMESTAMP);

            ps.setInt(7, e.getCapacity());
            ps.setInt(8, e.getSold());
            ps.setString(9, String.valueOf(e.getStatus()));
            ps.setBigDecimal(10, e.getPriceValue());

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) { if (rs.next()) return rs.getInt(1); }
        } catch (Exception ex) { throw new RuntimeException(ex); }
        return 0;
    }

    /** FIX: ahora también actualiza 'sold' */
    public boolean update(Event e) {
        String sql = """
          UPDATE events
          SET title=?, venue=?, genre=?, city=?, date_time=?, capacity=?, sold=?, status=?, price=?
          WHERE id=? AND organizer_id=?
        """;
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, e.getTitle());
            ps.setString(2, e.getVenue());
            ps.setString(3, e.getGenre());
            ps.setString(4, e.getCity());

            if (e.getDateTime()!=null) ps.setTimestamp(5, Timestamp.valueOf(e.getDateTime()));
            else ps.setNull(5, Types.TIMESTAMP);

            ps.setInt(6, e.getCapacity());
            ps.setInt(7, e.getSold()); // <-- importante
            ps.setString(8, String.valueOf(e.getStatus()));
            ps.setBigDecimal(9, e.getPriceValue());

            ps.setInt(10, e.getId());
            if (e.getOrganizerId()!=null) ps.setInt(11, e.getOrganizerId());
            else ps.setNull(11, Types.INTEGER);

            return ps.executeUpdate() > 0;
        } catch (Exception ex) { throw new RuntimeException(ex); }
    }

    public boolean delete(int id, int organizerId) {
        String sql = "DELETE FROM events WHERE id=? AND organizer_id=?";
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, organizerId);
            return ps.executeUpdate() > 0;
        } catch (Exception ex) { throw new RuntimeException(ex); }
    }

    public boolean toggleStatus(int id, int organizerId, String toStatus) {
        String to = (toStatus!=null ? toStatus.toUpperCase() : "BORRADOR");
        if (!List.of("PUBLICADO","BORRADOR","FINALIZADO").contains(to)) to = "BORRADOR";
        String sql = "UPDATE events SET status=? WHERE id=? AND organizer_id=?";
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, to);
            ps.setInt(2, id);
            ps.setInt(3, organizerId);
            return ps.executeUpdate() > 0;
        } catch (Exception ex) { throw new RuntimeException(ex); }
    }

    /* ============ Utilidades internas ============ */

    /** Enlaza parámetros con sus tipos */
    private void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        int idx = 1;
        for (Object o : params) {
            if (o instanceof Integer i)            ps.setInt(idx++, i);
            else if (o instanceof Long l)          ps.setLong(idx++, l);
            else if (o instanceof BigDecimal bd)   ps.setBigDecimal(idx++, bd);
            else if (o instanceof Timestamp t)     ps.setTimestamp(idx++, t);
            else                                    ps.setObject(idx++, o);
        }
    }
}
