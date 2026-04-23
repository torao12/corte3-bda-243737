const API_URL = "http://localhost:8000";
let currentUser = { role: "", vet_id: 1 }; // Por defecto 1 (Dr. López) para evitar errores FK

function login() {
    const sel = document.getElementById('role-select').value;
    
    if (sel === "vet_1") {
        currentUser = { role: "vet_role", vet_id: 1 };
    } else if (sel === "vet_2") {
        currentUser = { role: "vet_role", vet_id: 2 };
    } else {
        // Si es admin o recepcion, usamos el ID 1 para que la BD acepte el registro
        currentUser = { role: sel + "_role", vet_id: 1 }; 
    }

    document.getElementById('login-section').style.display = 'none';
    document.getElementById('app-content').style.display = 'block';
    document.getElementById('user-info-badge').innerHTML = `<span class="badge" style="background:#567C8D; color:white;">${sel.toUpperCase()}</span>`;
}

async function buscarMascota() {
    const nom = document.getElementById('search-input').value;
    const res = document.getElementById('search-results');
    try {
        const r = await fetch(`${API_URL}/mascotas/buscar?nombre=${nom}&vet_id=${currentUser.vet_id}`);
        const d = await r.json();
        res.innerHTML = d.length > 0 ? d.map(m => `<div class="content-card" style="margin-top:10px; border-left:5px solid #567C8D;"><strong>${m.nombre}</strong><br><small>${m.especie}</small></div>`).join('') : "<p>Sin resultados.</p>";
    } catch (e) { res.innerHTML = "Error de búsqueda."; }
}

async function cargarVacunasPendientes() {
    const ind = document.getElementById('cache-indicator');
    const body = document.getElementById('vacunas-body');
    const t0 = performance.now();
    try {
        const r = await fetch(`${API_URL}/mascotas/vacunacion-pendiente`);
        const d = await r.json();
        ind.innerText = `Latencia: ${(performance.now() - t0).toFixed(2)}ms`;
        body.innerHTML = d.map(v => `<tr><td>${v.mascota_nombre}</td><td>${v.vacuna_pendiente}</td><td>${v.dueno_nombre}</td><td><button class="btn-teal" onclick="aplicarVacuna(${v.mascota_id}, ${v.vacuna_id})">Vacunar</button></td></tr>`).join('');
    } catch (e) { ind.innerText = "Error de conexión."; }
}

async function aplicarVacuna(mId, vId) {
    try {
        const response = await fetch(`${API_URL}/vacunas/aplicar`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                mascota_id: parseInt(mId),
                vacuna_id: parseInt(vId),
                vet_id: parseInt(currentUser.vet_id), // Enviará 1 o 2, nunca 0
                costo: 350.0
            })
        });
        
        if (response.ok) {
            alert("Éxito: Vacuna registrada y caché invalidado.");
            cargarVacunasPendientes();
        } else {
            const err = await response.json();
            alert("Error en BD: " + err.detail);
        }
    } catch (e) {
        alert("Error de red.");
    }
}