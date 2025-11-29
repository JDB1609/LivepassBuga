package utils;

import java.io.Serializable;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class Event implements Serializable {

    public enum Status { PUBLICADO, BORRADOR, FINALIZADO, PENDIENTE, CANCELADO, RECHAZADO }

    private int id;
    private Integer organizerId;
    private String title;
    private String venue;

    // NUEVO
    private String genre = "";
    private String city  = "";

    private LocalDateTime dateTime;
    private int capacity = 0;
    private int sold = 0;
    private Status status = Status.BORRADOR;
    private BigDecimal price = BigDecimal.ZERO;

    private static final DateTimeFormatter DISPLAY_DMY =
            DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final NumberFormat CURRENCY_CO =
            NumberFormat.getCurrencyInstance(new Locale("es", "CO"));
    
    
    // Revision de Base de datos 15/11/2025 para incluir descripcion imagenes y foranea de administrador
    private String description;
    private String image;
    private Long approved_by;
    
    public Event() {}

    public Event(int id, String title, String venue, LocalDateTime dateTime,
                 int capacity, int sold, Status status, BigDecimal price, 
                 String description, String image) {
        this.id = id;
        this.title = title;
        this.venue = venue;
        this.dateTime = dateTime;
        this.capacity = Math.max(0, capacity);
        this.sold = Math.max(0, sold);
        this.status = (status != null ? status : Status.BORRADOR);
        this.price  = (price  != null ? price  : BigDecimal.ZERO);
        this.description = description;
        this.image = image;
    }

    // ===== Getters usados en vistas/DAO =====
    public int getId() { return id; }
    public Integer getOrganizerId() { return organizerId; }

    public String getTitle() { return title; }
    public String getVenue() { return venue; }

    // NUEVO
    public String getGenre() { return genre; }
    public String getCity()  { return city;  }

    /** dd/MM/yyyy para mostrar */
    public String getDate() { return dateTime != null ? DISPLAY_DMY.format(dateTime) : ""; }

    public LocalDateTime getDateTime() { return dateTime; }

    public int getCapacity() { return capacity; }
    public int getSold() { return sold; }
    public Status getStatus() { return status; }

    /** Para DAO/jdbc: BigDecimal */
    public BigDecimal getPrice() { return price; }

    /** Para JSP: precio formateado en COP */
    public String getPriceFormatted() { return CURRENCY_CO.format(price); }

    /** Alias si ya lo usabas en alguna parte */
    public BigDecimal getPriceValue() { return price; }
    
    
    //Agregados en el dia 15/11/2025
    public String getDescription() { return description; }
    
    public String getImage() { return image; }
    public Long getApproved_By() { return approved_by; }

    // ===== Setters =====
    public void setId(int id) { this.id = id; }
    public void setOrganizerId(Integer organizerId) { this.organizerId = organizerId; }
    public void setTitle(String title) { this.title = title; }
    public void setVenue(String venue) { this.venue = venue; }

    // NUEVO
    public void setGenre(String genre) { this.genre = (genre==null? "": genre.trim()); }
    public void setCity(String city)   { this.city  = (city==null?  "": city.trim()); }

    public void setDateTime(LocalDateTime dateTime) { this.dateTime = dateTime; }
    public void setCapacity(int capacity) { this.capacity = Math.max(0, capacity); }
    public void setSold(int sold) { this.sold = Math.max(0, sold); }

    public void setStatus(Status status) { this.status = (status != null ? status : Status.BORRADOR); }
    public void setStatus(String statusStr) {
        if (statusStr == null) return;
        try { this.status = Status.valueOf(statusStr.toUpperCase()); }
        catch (IllegalArgumentException ex) { this.status = Status.BORRADOR; }
    }
    
    

    public void setPrice(BigDecimal price) { this.price = (price != null ? price : BigDecimal.ZERO); }

    public void setPrice(String s) {
        if (s == null || s.trim().isEmpty()) { this.price = BigDecimal.ZERO; return; }
        s = s.trim().replaceAll("[^0-9,.-]", "");
        if (s.indexOf(',') >= 0 && s.indexOf('.') < 0) s = s.replace(".", "").replace(',', '.');
        else s = s.replace(",", "");
        try { this.price = new BigDecimal(s); }
        catch (NumberFormatException ex) { this.price = BigDecimal.ZERO; }
    }
    //Cambio a base de datos del 15/11/2025 para incluir  descripcion, imagen y 
    public void setDescription(String description) { this.description = (description==null? "": description.trim());}
    public void setImage(String image) { this.image = (image==null? "": image.trim());}
    public void setApproved_By(Long approved_by) { this.approved_by = approved_by; }
    

// ===== Utilidades =====
    public int getAvailability() { return Math.max(0, capacity - sold); }
    public boolean isPublicado()  { return status == Status.PUBLICADO; }
    public boolean isBorrador()   { return status == Status.BORRADOR; }
    public boolean isFinalizado() { return status == Status.FINALIZADO; }
    public boolean isPendiente() { return status == Status.PENDIENTE; }
    public boolean isRechazado() { return status == Status.RECHAZADO; }
    public boolean isCancelado() { return status == Status.CANCELADO; }
    
    @Override
    public String toString() {
        return "Event{" +
                "id=" + id +
                ", title='" + title + '\'' +
                ", venue='" + venue + '\'' +
                ", genre='" + genre + '\'' +
                ", city='" + city + '\'' +
                ", date=" + getDate() +
                ", capacity=" + capacity +
                ", sold=" + sold +
                ", status=" + status +
                ", price=" + price +
                ", descripcion=" + description +
                '}';
    }
}
