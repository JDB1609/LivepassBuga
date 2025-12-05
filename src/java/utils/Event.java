package utils;

import java.io.Serializable;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class Event implements Serializable {

    public enum Status {
        PUBLICADO,
        BORRADOR,
        FINALIZADO,   // REALIZADO en BD
        PENDIENTE,
        CANCELADO,
        RECHAZADO
    }

    private int id;
    private Long organizerId;

    private String title;
    private String venue;

    private String genre = "";
    private String city = "";
    private String categories = "";

    private String eventType = "";
    private String imageAlt = "";

    private LocalDateTime dateTime;
    private LocalDateTime createdAt;

    private Status status = Status.BORRADOR;

    private String description = "";
    private String image = "";

    // Agregados
    private int capacity = 0;
    private int sold = 0;
    private BigDecimal price = BigDecimal.ZERO;

    private static final DateTimeFormatter DISPLAY_DMY =
            DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private static final NumberFormat CURRENCY_CO =
            NumberFormat.getCurrencyInstance(new Locale("es", "CO"));

    public Event() {}

    // ================= GETTERS =================
    public int getId() { return id; }
    public Long getOrganizerId() { return organizerId; }

    public String getTitle() { return title; }
    public String getVenue() { return venue; }

    public String getGenre() { return genre; }
    public String getCity() { return city; }
    public String getCategories() { return categories; }

    public String getEventType() { return eventType; }
    public String getImageAlt() { return imageAlt; }

    public LocalDateTime getDateTime() { return dateTime; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    public Status getStatus() { return status; }

    public String getDescription() { return description; }
    public String getImage() { return image; }

    public int getCapacity() { return capacity; }
    public int getSold() { return sold; }

    public BigDecimal getPrice() { return price; }
    public BigDecimal getPriceValue() { return price; }

    public String getPriceFormatted() {
        return CURRENCY_CO.format(price);
    }

    public int getAvailability() {
        return Math.max(0, capacity - sold);
    }

    public String getDate() {
        return dateTime != null ? DISPLAY_DMY.format(dateTime) : "";
    }

    // ================= SETTERS =================
    public void setId(int id) { this.id = id; }

    public void setOrganizerId(Long organizerId) { this.organizerId = organizerId; }

    public void setTitle(String title) { this.title = title; }

    public void setVenue(String venue) { this.venue = venue; }

    public void setGenre(String genre) {
        this.genre = (genre == null ? "" : genre.trim());
    }

    public void setCity(String city) {
        this.city = (city == null ? "" : city.trim());
    }

    public void setCategories(String categories) {
        this.categories = (categories == null ? "" : categories.trim());
    }

    public void setEventType(String eventType) {
        this.eventType = (eventType == null ? "" : eventType.trim());
    }

    public void setImageAlt(String imageAlt) {
        this.imageAlt = (imageAlt == null ? "" : imageAlt.trim());
    }

    public void setDateTime(LocalDateTime dateTime) {
        this.dateTime = dateTime;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public void setStatus(Status status) {
        this.status = (status != null ? status : Status.BORRADOR);
    }

    public void setStatus(String statusStr) {
        if (statusStr == null) return;

        String s = statusStr.trim().toUpperCase();
        if ("REALIZADO".equals(s)) {
            this.status = Status.FINALIZADO;
            return;
        }

        try {
            this.status = Status.valueOf(s);
        } catch (Exception e) {
            this.status = Status.BORRADOR;
        }
    }

    public void setDescription(String description) {
        this.description = (description == null ? "" : description.trim());
    }

    public void setImage(String image) {
        this.image = (image == null ? "" : image.trim());
    }

    public void setCapacity(int capacity) {
        this.capacity = Math.max(0, capacity);
    }

    public void setSold(int sold) {
        this.sold = Math.max(0, sold);
    }

    public void setPrice(BigDecimal price) {
        this.price = (price != null ? price : BigDecimal.ZERO);
    }

    public void setPrice(String s) {
        if (s == null || s.trim().isEmpty()) {
            this.price = BigDecimal.ZERO;
            return;
        }

        s = s.replaceAll("[^0-9,.-]", "");

        if (s.contains(",") && !s.contains(".")) {
            s = s.replace(".", "").replace(',', '.');
        } else {
            s = s.replace(",", "");
        }

        try {
            this.price = new BigDecimal(s);
        } catch (Exception e) {
            this.price = BigDecimal.ZERO;
        }
    }

    public boolean isPublicado() { return status == Status.PUBLICADO; }
    public boolean isBorrador() { return status == Status.BORRADOR; }
    public boolean isFinalizado() { return status == Status.FINALIZADO; }
}
