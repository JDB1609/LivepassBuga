package utils;

import java.io.Serializable;
import java.sql.Timestamp;

public class Administrador implements Serializable {

    private int id;
    private String name;
    private String email;
    private String phone;
    private String passHash;
    private Timestamp createdAt;

    // --- Getters y Setters ---
    public int getId() { 
        return id; 
    }
    public void setId(int id) { 
        this.id = id; 
    }

    public String getName() { 
        return name; 
    }
    public void setName(String name) { 
        this.name = name; 
    }

    public String getEmail() { 
        return email; 
    }
    public void setEmail(String email) { 
        this.email = email; 
    }

    public String getPhone() { 
        return phone; 
    }
    public void setPhone(String phone) { 
        this.phone = phone; 
    }

    public String getPassHash() { 
        return passHash; 
    }
    public void setPassHash(String passHash) { 
        this.passHash = passHash; 
    }

    public Timestamp getCreatedAt() { 
        return createdAt; 
    }
    public void setCreatedAt(Timestamp createdAt) { 
        this.createdAt = createdAt; 
    }
}