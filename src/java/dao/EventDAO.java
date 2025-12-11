package dao;

import utils.Conexion;
import utils.Event;

import java.sql.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class EventDAO {

    // ==========================
    // SELECT BASE CON AGREGADOS
    // ==========================
    private static final String BASE_SELECT =
        "SELECT\n" +
        "    e.id,\n" +
        "    e.organizer_id,\n" +
        "    e.title,\n" +
        "    e.venue,\n" +
        "    e.genre,\n" +
        "    e.city,\n" +
        "    e.categories      AS category,\n" +
        "    e.type_events     AS event_type,\n" +
        "    e.text_acces      AS image_alt,\n" +
        "    e.date_time,\n" +
        "    e.description,\n" +
        "    e.image,\n" +
        "    e.status,\n" +
        "\n" +
        "    COALESCE(SUM(tt.capacity), 0)  AS capacity_total,\n" +
        "    COALESCE(SUM(t.qty), 0)        AS sold_total,\n" +
        "    COALESCE(MIN(tt.price), 0)     AS base_price\n" +
        "\n" +
        "FROM events e\n" +
        "LEFT JOIN ticket_types tt ON tt.id_event = e.id\n" +
        "LEFT JOIN tickets      t  ON t.event_id  = e.id\n";

    // ==========================
    // MAPPER
    // ==========================
    private Event map(ResultSet rs) throws SQLException {
        Event e = new Event();

        e.setId(rs.getInt("id"));

        long org = rs.getLong("organizer_id");
        if (!rs.wasNull()) e.setOrganizerId(org);

        e.setTitle(rs.getString("title"));
        e.setVenue(rs.getString("venue"));
        e.setGenre(rs.getString("genre"));
        e.setCity(rs.getString("city"));
        e.setCategories(rs.getString("category"));
        e.setEventType(rs.getString("event_type"));
        e.setImageAlt(rs.getString("image_alt"));

        Timestamp ts = rs.getTimestamp("date_time");
        if (ts != null) e.setDateTime(ts.toLocalDateTime());

        e.setCapacity(rs.getInt("capacity_total"));
        e.setSold(rs.getInt("sold_total"));
        e.setPrice(rs.getBigDecimal("base_price"));

        e.setDescription(rs.getString("description"));
        e.setImage(rs.getString("image"));
        e.setStatus(rs.getString("status"));   // setter convierte a enum internamente

        return e;
    }

    // ==========================
    // BIND DINÁMICO
    // ==========================
    private void bind(PreparedStatement ps, java.util.List<Object> params) throws SQLException {
        int i = 1;
        for (Object o : params) {
            if (o instanceof Integer)          ps.setInt(i++, (Integer) o);
            else if (o instanceof Long)        ps.setLong(i++, (Long) o);
            else if (o instanceof BigDecimal)  ps.setBigDecimal(i++, (BigDecimal) o);
            else                               ps.setObject(i++, o);
        }
    }

    // ==========================
    // STATUS JAVA (enum) → BD
    // ==========================
    private String toDbStatus(Event.Status st) {
        if (st == null) return "BORRADOR";

        switch (st) {
            case PUBLICADO:
                return "PUBLICADO";
            case FINALIZADO:
                return "REALIZADO";   // como definiste en la BD
            case PENDIENTE:
                return "PENDIENTE";
            case CANCELADO:
                return "CANCELADO";
            case RECHAZADO:
                return "RECHAZADO";
            default:
                return "BORRADOR";
        }
    }

    // ================= LISTADO ORGANIZADOR =================

    public java.util.List<Event> listByOrganizer(int organizerId, String q, String status) {

        StringBuilder sb = new StringBuilder(BASE_SELECT);
        java.util.List<Object> params = new java.util.ArrayList<Object>();

        sb.append(" WHERE e.organizer_id = ? ");
        params.add(organizerId);

        // (si quieres, aquí podrías filtrar por q/status)
        sb.append(" GROUP BY e.id ORDER BY e.date_time DESC ");

        java.util.List<Event> out = new java.util.ArrayList<Event>();

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {

            bind(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(map(rs));
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Error listByOrganizer", e);
        }

        return out;
    }

    // =============== BUSCAR EVENTO POR ID + ORGANIZADOR =================

    public Optional<Event> findByIdAndOrganizer(int id, int organizerId) {
        StringBuilder sb = new StringBuilder(BASE_SELECT);
        sb.append(" WHERE e.id = ? AND e.organizer_id = ? ");
        sb.append(" GROUP BY e.id ");

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {

            ps.setInt(1, id);
            ps.setInt(2, organizerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(map(rs));
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Error findByIdAndOrganizer", e);
        }

        return Optional.empty();
    }

    // ================= CREAR EVENTO =================

    public int create(Event e) {

        String sql =
            "INSERT INTO events(\n" +
            "    organizer_id,\n" +
            "    title,\n" +
            "    categories,\n" +
            "    genre,\n" +
            "    type_events,\n" +
            "    venue,\n" +
            "    city,\n" +
            "    date_time,\n" +
            "    status,\n" +
            "    description,\n" +
            "    image,\n" +
            "    text_acces\n" +
            ")\n" +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, e.getOrganizerId());
            ps.setString(2, e.getTitle());
            ps.setString(3, e.getCategories());
            ps.setString(4, e.getGenre());
            ps.setString(5, e.getEventType());
            ps.setString(6, e.getVenue());
            ps.setString(7, e.getCity());

            if (e.getDateTime() != null) {
                ps.setTimestamp(8, Timestamp.valueOf(e.getDateTime()));
            } else {
                ps.setNull(8, Types.TIMESTAMP);
            }

            ps.setString(9, toDbStatus(e.getStatus()));
            ps.setString(10, e.getDescription());
            ps.setString(11, e.getImage());
            ps.setString(12, e.getImageAlt()); // text_acces

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            throw new RuntimeException("Error create Event", ex);
        }

        return 0;
    }

    // ================= ZONAS / AFOROS =================

    public void insertZone(int eventId, String name, int capacity, BigDecimal price) {

        String sql =
            "INSERT INTO ticket_types (name, id_event, capacity, price)\n" +
            "VALUES (?,?,?,?)";

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setInt(2, eventId);
            ps.setInt(3, capacity);

            long priceValue = 0L;
            if (price != null) {
                priceValue = price.longValue();   // tu columna es BIGINT
            }
            ps.setLong(4, priceValue);

            System.out.println("[insertZone] eventId=" + eventId +
                    ", name=" + name +
                    ", cap=" + capacity +
                    ", price=" + priceValue);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Error insertZone", e);
        }
    }

    // ================= ACTUALIZAR EVENTO =================

    public void update(Event e, int organizerId) {

        String sql =
            "UPDATE events\n" +
            "SET\n" +
            "    title       = ?,\n" +
            "    categories  = ?,\n" +
            "    genre       = ?,\n" +
            "    type_events = ?,\n" +
            "    venue       = ?,\n" +
            "    city        = ?,\n" +
            "    date_time   = ?,\n" +
            "    status      = ?,\n" +
            "    description = ?,\n" +
            "    image       = ?,\n" +
            "    text_acces  = ?\n" +
            "WHERE id = ? AND organizer_id = ?";

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1,  e.getTitle());
            ps.setString(2,  e.getCategories());
            ps.setString(3,  e.getGenre());
            ps.setString(4,  e.getEventType());
            ps.setString(5,  e.getVenue());
            ps.setString(6,  e.getCity());

            if (e.getDateTime() != null) {
                ps.setTimestamp(7, Timestamp.valueOf(e.getDateTime()));
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }

            ps.setString(8,  toDbStatus(e.getStatus()));
            ps.setString(9,  e.getDescription());
            ps.setString(10, e.getImage());
            ps.setString(11, e.getImageAlt());

            ps.setInt(12, e.getId());
            ps.setInt(13, organizerId);

            int rows = ps.executeUpdate();
            if (rows == 0) {
                throw new RuntimeException(
                    "No se actualizó ningún evento (id=" + e.getId() +
                    ", organizer=" + organizerId + ")"
                );
            }

        } catch (Exception ex) {
            throw new RuntimeException("Error update Event", ex);
        }
    }

    // ================= ELIMINAR EVENTO =================

    public boolean delete(int eventId, int organizerId) {

        String sql = "DELETE FROM events WHERE id = ? AND organizer_id = ?";

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, eventId);
            ps.setInt(2, organizerId);

            int rows = ps.executeUpdate();

            if (rows == 0) {
                System.out.println("[EventDAO.delete] No se encontró evento " +
                                   eventId + " para organizer " + organizerId);
                return false;
            }

            System.out.println("[EventDAO.delete] Evento " + eventId +
                               " borrado por organizer " + organizerId);
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Error delete Event", e);
        }
    }

    // =============== LISTADO PARA HOME / CARRUSEL =================

    /**
     * Lista eventos PUBLICADOS para mostrar en el home (carrusel).
     * Ordenados por más vendidos y fecha más próxima.
     */
    public List<Event> listFeatured(int limit) {

        StringBuilder sb = new StringBuilder(BASE_SELECT);
        sb.append(" WHERE e.status = 'PUBLICADO' ");
        sb.append(" GROUP BY e.id ");
        sb.append(" ORDER BY sold_total DESC, e.date_time ASC ");

        if (limit > 0) {
            sb.append(" LIMIT ? ");
        }

        List<Event> out = new ArrayList<Event>();

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {

            if (limit > 0) {
                ps.setInt(1, limit);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(map(rs));
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Error listFeatured", e);
        }

        return out;
    }

    // =====================================================
    //  LISTAR GÉNEROS DISTINTOS
    // =====================================================
    public List<String> listGenres() {
        List<String> out = new ArrayList<String>();

        String sql = "SELECT DISTINCT genre " +
                     "FROM events " +
                     "WHERE genre IS NOT NULL AND genre <> '' " +
                     "ORDER BY genre";

        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = (cn != null ? cn.prepareStatement(sql) : null)) {

            if (ps == null) return out;

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String g = rs.getString(1);
                    if (g != null && !g.trim().isEmpty()) {
                        out.add(g.trim());
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return out;
    }

    // =====================================================
    //  LISTAR CIUDADES DISTINTAS
    // =====================================================
    public List<String> listCities() {
        List<String> out = new ArrayList<String>();

        String sql = "SELECT DISTINCT city " +
                     "FROM events " +
                     "WHERE city IS NOT NULL AND city <> '' " +
                     "ORDER BY city";

        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = (cn != null ? cn.prepareStatement(sql) : null)) {

            if (ps == null) return out;

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String c = rs.getString(1);
                    if (c != null && !c.trim().isEmpty()) {
                        out.add(c.trim());
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return out;
    }

    // ===============
    // LISTADO POPULARES
    // ===============
    public List<Event> listPopular(int limit) {

        StringBuilder sb = new StringBuilder(BASE_SELECT);
        sb.append(" WHERE e.status = ? ");          // solo PUBLICADO
        sb.append(" GROUP BY e.id ");
        sb.append(" ORDER BY sold_total DESC, e.date_time ASC ");
        if (limit > 0) {
            sb.append(" LIMIT ? ");
        }

        List<Object> params = new ArrayList<Object>();
        params.add("PUBLICADO");
        if (limit > 0) {
            params.add(limit);
        }

        List<Event> out = new ArrayList<Event>();

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {

            bind(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(map(rs));
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Error listPopular", e);
        }

        return out;
    }

    // =====================================================
    //  SEARCH + COUNTSEARCH PARA EXPLORAR EVENTOS
    // =====================================================

    /**
     * Búsqueda con filtros + paginación para ExplorarEventos.jsp
     */
    public List<Event> search(String q,
                              String genre,
                              String loc,
                              BigDecimal pmin,
                              BigDecimal pmax,
                              String order,
                              int page,
                              int pageSize) {

        StringBuilder sb = new StringBuilder(BASE_SELECT);
        List<Object> params = new ArrayList<Object>();

        sb.append(" WHERE e.status = 'PUBLICADO' ");

        if (q != null && !q.trim().isEmpty()) {
            sb.append(" AND (e.title LIKE ? OR e.venue LIKE ? OR e.city LIKE ?) ");
            String like = "%" + q.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        if (genre != null && !genre.trim().isEmpty()) {
            sb.append(" AND e.genre = ? ");
            params.add(genre.trim());
        }

        if (loc != null && !loc.trim().isEmpty()) {
            sb.append(" AND e.city = ? ");
            params.add(loc.trim());
        }

        // GROUP BY para poder usar los agregados (capacity_total, base_price, etc.)
        sb.append(" GROUP BY e.id ");

        // Filtro por precio sobre el MIN(tt.price) (alias base_price)
        boolean hasHaving = false;
        if (pmin != null) {
            sb.append(" HAVING base_price >= ? ");
            params.add(pmin);
            hasHaving = true;
        }
        if (pmax != null) {
            sb.append(hasHaving ? " AND base_price <= ? " : " HAVING base_price <= ? ");
            params.add(pmax);
        }

        // Orden
        if (order == null || order.trim().isEmpty() || "date".equals(order)) {
            sb.append(" ORDER BY e.date_time ASC ");
        } else if ("price_asc".equals(order)) {
            sb.append(" ORDER BY base_price ASC ");
        } else if ("price_desc".equals(order)) {
            sb.append(" ORDER BY base_price DESC ");
        } else {
            sb.append(" ORDER BY e.date_time ASC ");
        }

        // Paginación
        int offset = (page - 1) * pageSize;
        if (offset < 0) offset = 0;

        sb.append(" LIMIT ? OFFSET ? ");
        params.add(pageSize);
        params.add(offset);

        List<Event> out = new ArrayList<Event>();

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {

            bind(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(map(rs));
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Error search eventos", e);
        }

        return out;
    }

    /**
     * Total de eventos que cumplen los filtros (para calcular páginas)
     */
    public int countSearch(String q,
                           String genre,
                           String loc,
                           BigDecimal pmin,
                           BigDecimal pmax) {

        // construimos un SELECT interno usando la misma lógica que search(),
        // pero sin LIMIT/OFFSET ni ORDER BY, y lo envolvemos en un COUNT(*)
        StringBuilder inner = new StringBuilder(BASE_SELECT);
        List<Object> params = new ArrayList<Object>();

        inner.append(" WHERE e.status = 'PUBLICADO' ");

        if (q != null && !q.trim().isEmpty()) {
            inner.append(" AND (e.title LIKE ? OR e.venue LIKE ? OR e.city LIKE ?) ");
            String like = "%" + q.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        if (genre != null && !genre.trim().isEmpty()) {
            inner.append(" AND e.genre = ? ");
            params.add(genre.trim());
        }

        if (loc != null && !loc.trim().isEmpty()) {
            inner.append(" AND e.city = ? ");
            params.add(loc.trim());
        }

        inner.append(" GROUP BY e.id ");

        boolean hasHaving = false;
        if (pmin != null) {
            inner.append(" HAVING base_price >= ? ");
            params.add(pmin);
            hasHaving = true;
        }
        if (pmax != null) {
            inner.append(hasHaving ? " AND base_price <= ? " : " HAVING base_price <= ? ");
            params.add(pmax);
        }

        String sql = "SELECT COUNT(*) FROM (" + inner.toString() + ") AS sub";

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            bind(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Error countSearch eventos", e);
        }

        return 0;
    }

    // ===============
    // BUSCAR EVENTO SOLO POR ID (página pública)
    // ===============
    public Optional<Event> findById(int id) {
        StringBuilder sb = new StringBuilder(BASE_SELECT);
        sb.append(" WHERE e.id = ? ");
        sb.append(" GROUP BY e.id ");

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(map(rs));
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Error findById", e);
        }

        return Optional.empty();
    }

    // =====================================================
    //  ZONAS / TICKET TYPES POR EVENTO
    // =====================================================

    public static class EventZone {
        private int id;
        private String name;
        private int capacity;
        private long price;
        private int sold;

        public int getId()        { return id; }
        public String getName()   { return name; }
        public int getCapacity()  { return capacity; }
        public long getPrice()    { return price; }
        public int getSold()      { return sold; }
        public int getAvailable() { return Math.max(0, capacity - sold); }

        public void setId(int id)               { this.id = id; }
        public void setName(String name)        { this.name = name; }
        public void setCapacity(int capacity)   { this.capacity = capacity; }
        public void setPrice(long price)        { this.price = price; }
        public void setSold(int sold)           { this.sold = sold; }
    }

    /**
     * Zonas (ticket_types) de un evento con aforo, precio y vendidos.
     * Ajusta "ticket_type_id" si tu tabla tickets usa otro nombre.
     */
    public List<EventZone> listZonesByEvent(int eventId) {

        String sql =
            "SELECT\n" +
            "    tt.id,\n" +
            "    tt.name,\n" +
            "    tt.capacity,\n" +
            "    tt.price,\n" +
            "    COALESCE(SUM(t.qty), 0) AS sold\n" +
            "FROM ticket_types tt\n" +
            "LEFT JOIN tickets t\n" +
            "       ON t.ticket_type_id = tt.id   -- CAMBIA SI TU COLUMNA SE LLAMA DISTINTO\n" +
            "      AND t.event_id       = tt.id_event\n" +
            "WHERE tt.id_event = ?\n" +
            "GROUP BY tt.id, tt.name, tt.capacity, tt.price\n" +
            "ORDER BY tt.name";

        List<EventZone> out = new ArrayList<EventZone>();

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, eventId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EventZone z = new EventZone();
                    z.setId(rs.getInt("id"));
                    z.setName(rs.getString("name"));
                    z.setCapacity(rs.getInt("capacity"));
                    z.setPrice(rs.getLong("price"));
                    z.setSold(rs.getInt("sold"));
                    out.add(z);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Error listZonesByEvent", e);
        }

        return out;
    }
    
    public Event obtenerPorId(int idEvento) {
        Event ev = null;
        String sql = "SELECT id, organizer_id, title, categories, genre, type_events, venue, city, date_time, status, created_at, description, image FROM events WHERE id = ?";

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, idEvento);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ev = new Event();
                    ev.setId(rs.getInt("id"));
                    ev.setOrganizerId(rs.getLong("organizer_id"));
                    ev.setTitle(rs.getString("title"));
                    ev.setCategories(rs.getString("categories"));
                    ev.setGenre(rs.getString("genre"));
                    ev.setEventType(rs.getString("type_events"));
                    ev.setVenue(rs.getString("venue"));
                    ev.setCity(rs.getString("city"));

                    // Mapeo de fecha y hora
                    Timestamp ts = rs.getTimestamp("date_time");
                    if (ts != null) {
                        ev.setDateTime(ts.toLocalDateTime());
                    }

                    ev.setStatus(rs.getString("status"));
                    ev.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    ev.setDescription(rs.getString("description"));
                    ev.setImage(rs.getString("image"));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error obteniendo evento por ID: " + e.getMessage(), e);
        }

        return ev;

   }
}
