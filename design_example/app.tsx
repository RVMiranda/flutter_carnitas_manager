import { useState } from 'react'

type Tab = 'tables' | 'menu' | 'qr' | 'employees' | 'promotions'

interface Table {
  id: number
  status: 'occupied' | 'free' | 'reserved'
  guests?: number
  order?: string
  time?: string
}

interface MenuItem {
  id: number
  name: string
  category: string
  stock: number
  maxStock: number
  price: number
  emoji: string
}

interface Employee {
  id: number
  name: string
  role: string
  shift: string
  status: 'active' | 'off'
  avatar: string
}

interface Promo {
  id: number
  title: string
  discount: string
  validity: string
  active: boolean
  emoji: string
}

const TABLES: Table[] = [
  { id: 1, status: 'occupied', guests: 4, order: 'Tacos al pastor x4, Agua de jamaica', time: '18 min' },
  { id: 2, status: 'free' },
  { id: 3, status: 'occupied', guests: 2, order: 'Quesadillas x2, Refresco', time: '5 min' },
  { id: 4, status: 'reserved' },
  { id: 5, status: 'occupied', guests: 6, order: 'Orden mixta, Guacamole x2', time: '32 min' },
  { id: 6, status: 'free' },
  { id: 7, status: 'free' },
  { id: 8, status: 'occupied', guests: 3, order: 'Tacos de barbacoa x6', time: '11 min' },
  { id: 9, status: 'free' },
  { id: 10, status: 'occupied', guests: 2, order: 'Sopa de lima, Agua mineral', time: '44 min' },
  { id: 11, status: 'free' },
  { id: 12, status: 'reserved' },
]

const MENU_ITEMS: MenuItem[] = [
  { id: 1, name: 'Tacos al Pastor', category: 'Tacos', stock: 48, maxStock: 60, price: 25, emoji: '🌮' },
  { id: 2, name: 'Tacos de Barbacoa', category: 'Tacos', stock: 12, maxStock: 60, price: 28, emoji: '🥩' },
  { id: 3, name: 'Quesadillas de Queso', category: 'Antojitos', stock: 30, maxStock: 40, price: 35, emoji: '🫓' },
  { id: 4, name: 'Guacamole Casero', category: 'Entradas', stock: 5, maxStock: 30, price: 55, emoji: '🥑' },
  { id: 5, name: 'Agua de Jamaica', category: 'Bebidas', stock: 22, maxStock: 50, price: 20, emoji: '🫙' },
  { id: 6, name: 'Agua de Horchata', category: 'Bebidas', stock: 18, maxStock: 50, price: 20, emoji: '🥛' },
  { id: 7, name: 'Sopa de Lima', category: 'Caldos', stock: 8, maxStock: 25, price: 65, emoji: '🍲' },
  { id: 8, name: 'Pozole Rojo', category: 'Caldos', stock: 3, maxStock: 25, price: 75, emoji: '🥣' },
  { id: 9, name: 'Orden de Tostadas', category: 'Antojitos', stock: 25, maxStock: 35, price: 45, emoji: '🥙' },
]

const EMPLOYEES: Employee[] = [
  { id: 1, name: 'Lucía Ramírez', role: 'Cajera', shift: '09:00 – 18:00', status: 'active', avatar: 'LR' },
  { id: 2, name: 'Carlos Mendoza', role: 'Mesero', shift: '12:00 – 21:00', status: 'active', avatar: 'CM' },
  { id: 3, name: 'Fernanda Torres', role: 'Cocinera', shift: '07:00 – 15:00', status: 'active', avatar: 'FT' },
  { id: 4, name: 'Miguel Ángel Ríos', role: 'Mesero', shift: '15:00 – 23:00', status: 'off', avatar: 'MR' },
  { id: 5, name: 'Daniela Vega', role: 'Hostess', shift: '13:00 – 22:00', status: 'active', avatar: 'DV' },
  { id: 6, name: 'Iván Castellanos', role: 'Cocinero', shift: '07:00 – 15:00', status: 'off', avatar: 'IC' },
]

const PROMOS: Promo[] = [
  { id: 1, title: 'Martes de Tacos 2x1', discount: '50% en tacos', validity: 'Todos los martes', active: true, emoji: '🔥' },
  { id: 2, title: 'Combo Familiar', discount: '$299 por 20 tacos + 4 aguas', validity: 'Hasta el 31 Ago 2026', active: true, emoji: '👨‍👩‍👧‍👦' },
  { id: 3, title: 'Happy Hour', discount: '2x1 en bebidas', validity: 'Lun–Vie 15:00–17:00', active: false, emoji: '🥤' },
  { id: 4, title: 'Cumpleañero VIP', discount: 'Postre gratis + 10% off', validity: 'Previa reservación', active: true, emoji: '🎂' },
  { id: 5, title: 'Primera Visita', discount: '$30 de descuento', validity: 'Solo con app activa', active: false, emoji: '⭐' },
]

function StockBar({ stock, max }: { stock: number; max: number }) {
  const pct = (stock / max) * 100
  const color = pct > 50 ? '#22C55E' : pct > 20 ? '#F5A623' : '#D94F3D'
  return (
    <div className="flex items-center gap-2 mt-1">
      <div className="flex-1 h-1.5 rounded-full" style={{ backgroundColor: 'var(--border)' }}>
        <div
          className="h-1.5 rounded-full transition-all"
          style={{ width: `${pct}%`, backgroundColor: color }}
        />
      </div>
      <span className="text-xs font-medium tabular-nums" style={{ color: 'var(--muted-foreground)', minWidth: 28 }}>
        {stock}/{max}
      </span>
    </div>
  )
}

function TablesScreen() {
  const [selectedTable, setSelectedTable] = useState<Table | null>(null)

  return (
    <div className="p-4">
      <div className="flex items-center justify-between mb-5">
        <div>
          <h1 className="text-2xl font-semibold" style={{ fontFamily: 'Fraunces, serif', color: 'var(--foreground)' }}>
            Salón
          </h1>
          <p className="text-sm mt-0.5" style={{ color: 'var(--muted-foreground)' }}>
            {TABLES.filter(t => t.status === 'occupied').length} de {TABLES.length} mesas ocupadas
          </p>
        </div>
        <div className="flex gap-3 text-xs font-medium" style={{ color: 'var(--muted-foreground)' }}>
          <span className="flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full" style={{ backgroundColor: 'var(--primary)' }} />
            Ocupada
          </span>
          <span className="flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full" style={{ backgroundColor: 'var(--muted-foreground)', opacity: 0.4 }} />
            Libre
          </span>
          <span className="flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full" style={{ backgroundColor: 'var(--accent)' }} />
            Reservada
          </span>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-3 sm:grid-cols-4">
        {TABLES.map(table => (
          <button
            key={table.id}
            onClick={() => setSelectedTable(table.id === selectedTable?.id ? null : table)}
            className="aspect-square rounded-2xl flex flex-col items-center justify-center gap-1 transition-all active:scale-95"
            style={{
              backgroundColor:
                table.status === 'occupied'
                  ? 'var(--primary)'
                  : table.status === 'reserved'
                  ? 'var(--accent)'
                  : 'var(--card)',
              color:
                table.status === 'occupied'
                  ? '#fff'
                  : table.status === 'reserved'
                  ? 'var(--accent-foreground)'
                  : 'var(--muted-foreground)',
              boxShadow:
                table.status === 'free'
                  ? '0 2px 8px rgba(0,0,0,0.06)'
                  : table.status === 'occupied'
                  ? '0 4px 16px rgba(217, 79, 61, 0.35)'
                  : '0 4px 16px rgba(245, 166, 35, 0.3)',
              border: selectedTable?.id === table.id ? '2px solid var(--foreground)' : '2px solid transparent',
            }}
          >
            <span className="text-xl">🪑</span>
            <span className="text-sm font-semibold">{table.id}</span>
            {table.status === 'occupied' && (
              <span className="text-xs opacity-80">{table.guests}p · {table.time}</span>
            )}
            {table.status === 'reserved' && (
              <span className="text-xs font-medium">Reservada</span>
            )}
            {table.status === 'free' && (
              <span className="text-xs">Libre</span>
            )}
          </button>
        ))}
      </div>

      {selectedTable && selectedTable.status === 'occupied' && (
        <div
          className="mt-4 p-4 rounded-2xl"
          style={{ backgroundColor: 'var(--card)', boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }}
        >
          <div className="flex items-center justify-between mb-2">
            <h3 className="font-semibold" style={{ color: 'var(--foreground)' }}>
              Mesa {selectedTable.id} · {selectedTable.guests} personas
            </h3>
            <span className="text-xs px-2.5 py-1 rounded-full font-medium" style={{ backgroundColor: 'var(--secondary)', color: 'var(--muted-foreground)' }}>
              {selectedTable.time} esperando
            </span>
          </div>
          <p className="text-sm" style={{ color: 'var(--muted-foreground)' }}>{selectedTable.order}</p>
          <div className="flex gap-2 mt-3">
            <button className="flex-1 py-2 rounded-xl text-sm font-medium transition-all active:scale-95" style={{ backgroundColor: 'var(--primary)', color: '#fff' }}>
              Ver pedido
            </button>
            <button className="flex-1 py-2 rounded-xl text-sm font-medium transition-all active:scale-95" style={{ backgroundColor: 'var(--secondary)', color: 'var(--foreground)' }}>
              Cobrar
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

function MenuScreen() {
  const categories = [...new Set(MENU_ITEMS.map(i => i.category))]
  const [activeCategory, setActiveCategory] = useState('Todos')

  const filtered =
    activeCategory === 'Todos' ? MENU_ITEMS : MENU_ITEMS.filter(i => i.category === activeCategory)

  return (
    <div className="p-4">
      <div className="mb-5">
        <h1 className="text-2xl font-semibold" style={{ fontFamily: 'Fraunces, serif', color: 'var(--foreground)' }}>
          Menú e Inventario
        </h1>
        <p className="text-sm mt-0.5" style={{ color: 'var(--muted-foreground)' }}>
          {MENU_ITEMS.filter(i => i.stock / i.maxStock < 0.2).length} productos en stock bajo
        </p>
      </div>

      <div className="flex gap-2 overflow-x-auto pb-2 mb-4">
        {['Todos', ...categories].map(cat => (
          <button
            key={cat}
            onClick={() => setActiveCategory(cat)}
            className="shrink-0 px-4 py-1.5 rounded-full text-sm font-medium transition-all"
            style={{
              backgroundColor: activeCategory === cat ? 'var(--primary)' : 'var(--card)',
              color: activeCategory === cat ? '#fff' : 'var(--muted-foreground)',
              boxShadow: activeCategory === cat ? '0 2px 8px rgba(217,79,61,0.3)' : '0 1px 4px rgba(0,0,0,0.06)',
            }}
          >
            {cat}
          </button>
        ))}
      </div>

      <div className="flex flex-col gap-3">
        {filtered.map(item => (
          <div
            key={item.id}
            className="flex items-center gap-3 p-3 rounded-2xl"
            style={{ backgroundColor: 'var(--card)', boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}
          >
            <div
              className="w-12 h-12 rounded-xl flex items-center justify-center text-2xl shrink-0"
              style={{ backgroundColor: 'var(--secondary)' }}
            >
              {item.emoji}
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between">
                <span className="text-sm font-semibold truncate" style={{ color: 'var(--foreground)' }}>
                  {item.name}
                </span>
                <span className="text-sm font-medium ml-2 shrink-0" style={{ color: 'var(--primary)' }}>
                  ${item.price}
                </span>
              </div>
              <span className="text-xs" style={{ color: 'var(--muted-foreground)' }}>{item.category}</span>
              <StockBar stock={item.stock} max={item.maxStock} />
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

function QRScreen() {
  const [scanned, setScanned] = useState(false)
  const [code, setCode] = useState('')

  const mockScan = () => setScanned(true)

  return (
    <div className="flex flex-col h-full">
      <div className="p-4 pb-0">
        <h1 className="text-2xl font-semibold" style={{ fontFamily: 'Fraunces, serif', color: 'var(--foreground)' }}>
          Lealtad QR
        </h1>
        <p className="text-sm mt-0.5" style={{ color: 'var(--muted-foreground)' }}>
          Escanea el código del cliente
        </p>
      </div>

      {/* Camera viewfinder */}
      <div
        className="mx-4 mt-4 rounded-3xl overflow-hidden relative flex items-center justify-center"
        style={{ aspectRatio: '4/3', backgroundColor: '#0F1523', flexShrink: 0 }}
      >
        {/* Simulated camera with gradient overlay */}
        <div className="absolute inset-0" style={{ background: 'linear-gradient(135deg, #1a2744 0%, #0f1523 100%)' }} />
        <div className="absolute inset-0 opacity-10" style={{
          backgroundImage: 'linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px)',
          backgroundSize: '30px 30px'
        }} />

        {/* Scan frame */}
        <div className="relative z-10 w-44 h-44">
          {['top-0 left-0', 'top-0 right-0 rotate-90', 'bottom-0 right-0 rotate-180', 'bottom-0 left-0 -rotate-90'].map((pos, i) => (
            <div key={i} className={`absolute ${pos} w-8 h-8`}>
              <div className="absolute top-0 left-0 w-full h-0.5 rounded-full" style={{ backgroundColor: 'var(--accent)' }} />
              <div className="absolute top-0 left-0 h-full w-0.5 rounded-full" style={{ backgroundColor: 'var(--accent)' }} />
            </div>
          ))}
          <div className="absolute inset-0 flex items-center justify-center">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.3)" strokeWidth="1.5">
              <rect x="3" y="3" width="7" height="7" rx="1" />
              <rect x="14" y="3" width="7" height="7" rx="1" />
              <rect x="3" y="14" width="7" height="7" rx="1" />
              <rect x="14" y="14" width="3" height="3" />
              <rect x="19" y="14" width="2" height="2" />
              <rect x="14" y="19" width="2" height="2" />
              <rect x="18" y="18" width="3" height="3" />
            </svg>
          </div>
        </div>

        <button
          onClick={mockScan}
          className="absolute bottom-4 right-4 px-4 py-2 rounded-xl text-xs font-semibold transition-all active:scale-95"
          style={{ backgroundColor: 'var(--accent)', color: 'var(--accent-foreground)' }}
        >
          Simular escaneo
        </button>
      </div>

      {/* Bottom info card */}
      <div
        className="mx-4 mt-4 p-4 rounded-2xl flex-1"
        style={{ backgroundColor: 'var(--card)', boxShadow: '0 4px 24px rgba(0,0,0,0.10)' }}
      >
        {scanned ? (
          <>
            <div className="flex items-center gap-3 mb-4">
              <div className="w-12 h-12 rounded-full flex items-center justify-center text-xl font-semibold" style={{ backgroundColor: 'var(--secondary)', color: 'var(--primary)' }}>
                MG
              </div>
              <div>
                <p className="font-semibold" style={{ color: 'var(--foreground)' }}>María González</p>
                <p className="text-xs" style={{ color: 'var(--muted-foreground)' }}>Cliente desde Mar 2024 · 1,240 pts</p>
              </div>
              <div className="ml-auto px-3 py-1 rounded-full text-xs font-semibold" style={{ backgroundColor: 'var(--accent)', color: 'var(--accent-foreground)' }}>
                Nivel Oro
              </div>
            </div>
            <div className="grid grid-cols-3 gap-2 mb-4">
              {[['Visitas', '47'], ['Pts canjeados', '800'], ['Ahorro total', '$320']].map(([label, val]) => (
                <div key={label} className="rounded-xl p-2.5 text-center" style={{ backgroundColor: 'var(--secondary)' }}>
                  <p className="text-base font-semibold" style={{ color: 'var(--foreground)' }}>{val}</p>
                  <p className="text-xs" style={{ color: 'var(--muted-foreground)' }}>{label}</p>
                </div>
              ))}
            </div>
            <button className="w-full py-3 rounded-xl font-semibold text-sm transition-all active:scale-95" style={{ backgroundColor: 'var(--primary)', color: '#fff' }}>
              Aplicar descuento de lealtad
            </button>
            <button onClick={() => setScanned(false)} className="w-full py-2 mt-2 rounded-xl text-sm transition-all" style={{ color: 'var(--muted-foreground)' }}>
              Cancelar
            </button>
          </>
        ) : (
          <>
            <p className="text-sm font-medium mb-3" style={{ color: 'var(--foreground)' }}>O ingresa el código manualmente</p>
            <div className="flex gap-2">
              <input
                type="text"
                placeholder="Ej: TAQ-20481"
                value={code}
                onChange={e => setCode(e.target.value)}
                className="flex-1 px-4 py-2.5 rounded-xl text-sm outline-none"
                style={{
                  backgroundColor: 'var(--secondary)',
                  color: 'var(--foreground)',
                  border: '1.5px solid var(--border)',
                  fontFamily: 'Outfit, sans-serif'
                }}
              />
              <button
                onClick={mockScan}
                className="px-4 py-2.5 rounded-xl text-sm font-semibold transition-all active:scale-95"
                style={{ backgroundColor: 'var(--primary)', color: '#fff' }}
              >
                Buscar
              </button>
            </div>
            <p className="text-xs mt-3" style={{ color: 'var(--muted-foreground)' }}>
              El cliente puede encontrar su código en la app de lealtad Taquería.
            </p>
          </>
        )}
      </div>
    </div>
  )
}

function EmployeesScreen() {
  const [showForm, setShowForm] = useState(false)

  return (
    <div className="p-4 relative">
      <div className="mb-5">
        <h1 className="text-2xl font-semibold" style={{ fontFamily: 'Fraunces, serif', color: 'var(--foreground)' }}>
          Empleados
        </h1>
        <p className="text-sm mt-0.5" style={{ color: 'var(--muted-foreground)' }}>
          {EMPLOYEES.filter(e => e.status === 'active').length} activos hoy
        </p>
      </div>

      <div className="flex flex-col gap-3">
        {EMPLOYEES.map(emp => (
          <div
            key={emp.id}
            className="flex items-center gap-3 p-3 rounded-2xl"
            style={{ backgroundColor: 'var(--card)', boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}
          >
            <div
              className="w-11 h-11 rounded-full flex items-center justify-center text-sm font-semibold shrink-0"
              style={{
                backgroundColor: emp.status === 'active' ? 'var(--secondary)' : 'var(--muted)',
                color: emp.status === 'active' ? 'var(--primary)' : 'var(--muted-foreground)',
              }}
            >
              {emp.avatar}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-semibold truncate" style={{ color: 'var(--foreground)' }}>{emp.name}</p>
              <p className="text-xs" style={{ color: 'var(--muted-foreground)' }}>{emp.role} · {emp.shift}</p>
            </div>
            <div
              className="px-2.5 py-1 rounded-full text-xs font-medium shrink-0"
              style={{
                backgroundColor: emp.status === 'active' ? 'rgba(34, 197, 94, 0.12)' : 'var(--muted)',
                color: emp.status === 'active' ? '#16A34A' : 'var(--muted-foreground)',
              }}
            >
              {emp.status === 'active' ? 'Activo' : 'Descansando'}
            </div>
          </div>
        ))}
      </div>

      {/* FAB */}
      <button
        onClick={() => setShowForm(true)}
        className="fixed bottom-24 right-5 w-14 h-14 rounded-full flex items-center justify-center text-2xl shadow-lg transition-all active:scale-90 z-30"
        style={{ backgroundColor: 'var(--primary)', color: '#fff', boxShadow: '0 6px 24px rgba(217,79,61,0.4)' }}
      >
        +
      </button>

      {showForm && (
        <div className="fixed inset-0 z-40 flex items-end" style={{ backgroundColor: 'rgba(0,0,0,0.4)' }} onClick={() => setShowForm(false)}>
          <div
            className="w-full p-5 rounded-t-3xl"
            style={{ backgroundColor: 'var(--card)' }}
            onClick={e => e.stopPropagation()}
          >
            <h3 className="text-lg font-semibold mb-4" style={{ fontFamily: 'Fraunces, serif', color: 'var(--foreground)' }}>
              Nuevo Empleado
            </h3>
            {['Nombre completo', 'Puesto / Rol', 'Horario de turno'].map(label => (
              <div key={label} className="mb-3">
                <label className="text-xs font-medium mb-1 block" style={{ color: 'var(--muted-foreground)' }}>{label}</label>
                <input
                  placeholder={label}
                  className="w-full px-4 py-2.5 rounded-xl text-sm outline-none"
                  style={{ backgroundColor: 'var(--secondary)', color: 'var(--foreground)', border: '1.5px solid var(--border)', fontFamily: 'Outfit, sans-serif' }}
                />
              </div>
            ))}
            <button
              onClick={() => setShowForm(false)}
              className="w-full py-3 rounded-xl font-semibold text-sm mt-2 transition-all active:scale-95"
              style={{ backgroundColor: 'var(--primary)', color: '#fff' }}
            >
              Guardar empleado
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

function PromosScreen() {
  const [promos, setPromos] = useState(PROMOS)
  const [showForm, setShowForm] = useState(false)

  const togglePromo = (id: number) => {
    setPromos(prev => prev.map(p => p.id === id ? { ...p, active: !p.active } : p))
  }

  return (
    <div className="p-4 relative">
      <div className="mb-5">
        <h1 className="text-2xl font-semibold" style={{ fontFamily: 'Fraunces, serif', color: 'var(--foreground)' }}>
          Promociones
        </h1>
        <p className="text-sm mt-0.5" style={{ color: 'var(--muted-foreground)' }}>
          {promos.filter(p => p.active).length} activas actualmente
        </p>
      </div>

      <div className="flex flex-col gap-3">
        {promos.map(promo => (
          <div
            key={promo.id}
            className="p-4 rounded-2xl"
            style={{
              backgroundColor: 'var(--card)',
              boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
              opacity: promo.active ? 1 : 0.6,
            }}
          >
            <div className="flex items-start gap-3">
              <div
                className="w-11 h-11 rounded-xl flex items-center justify-center text-xl shrink-0"
                style={{ backgroundColor: 'var(--secondary)' }}
              >
                {promo.emoji}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between gap-2">
                  <p className="text-sm font-semibold" style={{ color: 'var(--foreground)' }}>{promo.title}</p>
                  {/* Toggle */}
                  <button
                    onClick={() => togglePromo(promo.id)}
                    className="shrink-0 w-11 h-6 rounded-full transition-all relative"
                    style={{ backgroundColor: promo.active ? 'var(--primary)' : 'var(--muted)' }}
                  >
                    <div
                      className="absolute top-0.5 w-5 h-5 rounded-full bg-white transition-all shadow-sm"
                      style={{ left: promo.active ? 'calc(100% - 22px)' : '2px' }}
                    />
                  </button>
                </div>
                <p className="text-xs mt-0.5" style={{ color: 'var(--primary)' }}>{promo.discount}</p>
                <p className="text-xs mt-0.5" style={{ color: 'var(--muted-foreground)' }}>{promo.validity}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* FAB */}
      <button
        onClick={() => setShowForm(true)}
        className="fixed bottom-24 right-5 w-14 h-14 rounded-full flex items-center justify-center text-2xl shadow-lg transition-all active:scale-90 z-30"
        style={{ backgroundColor: 'var(--accent)', color: 'var(--accent-foreground)', boxShadow: '0 6px 24px rgba(245,166,35,0.4)' }}
      >
        +
      </button>

      {showForm && (
        <div className="fixed inset-0 z-40 flex items-end" style={{ backgroundColor: 'rgba(0,0,0,0.4)' }} onClick={() => setShowForm(false)}>
          <div
            className="w-full p-5 rounded-t-3xl"
            style={{ backgroundColor: 'var(--card)' }}
            onClick={e => e.stopPropagation()}
          >
            <h3 className="text-lg font-semibold mb-4" style={{ fontFamily: 'Fraunces, serif', color: 'var(--foreground)' }}>
              Nueva Promoción
            </h3>
            {['Nombre de la promo', 'Descuento o beneficio', 'Vigencia'].map(label => (
              <div key={label} className="mb-3">
                <label className="text-xs font-medium mb-1 block" style={{ color: 'var(--muted-foreground)' }}>{label}</label>
                <input
                  placeholder={label}
                  className="w-full px-4 py-2.5 rounded-xl text-sm outline-none"
                  style={{ backgroundColor: 'var(--secondary)', color: 'var(--foreground)', border: '1.5px solid var(--border)', fontFamily: 'Outfit, sans-serif' }}
                />
              </div>
            ))}
            <button
              onClick={() => setShowForm(false)}
              className="w-full py-3 rounded-xl font-semibold text-sm mt-2 transition-all active:scale-95"
              style={{ backgroundColor: 'var(--accent)', color: 'var(--accent-foreground)' }}
            >
              Guardar promoción
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

function SettingsSheet({ onClose }: { onClose: () => void }) {
  return (
    <div className="fixed inset-0 z-50 flex items-end" style={{ backgroundColor: 'rgba(0,0,0,0.4)' }} onClick={onClose}>
      <div
        className="w-full p-5 rounded-t-3xl"
        style={{ backgroundColor: 'var(--card)' }}
        onClick={e => e.stopPropagation()}
      >
        <h3 className="text-lg font-semibold mb-4" style={{ fontFamily: 'Fraunces, serif', color: 'var(--foreground)' }}>
          Más opciones
        </h3>
        {[
          { icon: '📊', label: 'Gráficas de ventas', sub: 'Resumen del día y semana' },
          { icon: '🧾', label: 'Cierre de caja', sub: 'Corte al final del turno' },
          { icon: '⚙️', label: 'Configuración', sub: 'Preferencias del sistema' },
          { icon: '🔔', label: 'Notificaciones', sub: 'Alertas y avisos' },
          { icon: '🚪', label: 'Cerrar sesión', sub: 'Salir de la cuenta actual' },
        ].map(item => (
          <button
            key={item.label}
            className="flex items-center gap-3 w-full py-3 text-left transition-all"
            style={{ borderBottom: '1px solid var(--border)' }}
          >
            <span className="text-xl w-8 text-center">{item.icon}</span>
            <div>
              <p className="text-sm font-medium" style={{ color: 'var(--foreground)' }}>{item.label}</p>
              <p className="text-xs" style={{ color: 'var(--muted-foreground)' }}>{item.sub}</p>
            </div>
          </button>
        ))}
      </div>
    </div>
  )
}

const NAV_TABS = [
  { id: 'tables' as Tab, icon: TablesIcon, label: 'Mesas' },
  { id: 'menu' as Tab, icon: MenuIcon, label: 'Menú' },
  { id: 'qr' as Tab, icon: QRIcon, label: 'QR', center: true },
  { id: 'employees' as Tab, icon: EmployeesIcon, label: 'Equipo' },
  { id: 'promotions' as Tab, icon: PromosIcon, label: 'Promos' },
]

function TablesIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={active ? 2.2 : 1.8} strokeLinecap="round">
      <rect x="3" y="7" width="18" height="3" rx="1.5" />
      <line x1="7" y1="10" x2="7" y2="18" />
      <line x1="17" y1="10" x2="17" y2="18" />
      <line x1="5" y1="18" x2="19" y2="18" />
    </svg>
  )
}

function MenuIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={active ? 2.2 : 1.8} strokeLinecap="round">
      <rect x="3" y="3" width="7" height="7" rx="1.5" />
      <line x1="14" y1="5" x2="21" y2="5" />
      <line x1="14" y1="9" x2="21" y2="9" />
      <rect x="3" y="14" width="7" height="7" rx="1.5" />
      <line x1="14" y1="16" x2="21" y2="16" />
      <line x1="14" y1="20" x2="21" y2="20" />
    </svg>
  )
}

function QRIcon({ active }: { active: boolean }) {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={active ? 2.2 : 2} strokeLinecap="round">
      <rect x="3" y="3" width="7" height="7" rx="1" />
      <rect x="14" y="3" width="7" height="7" rx="1" />
      <rect x="3" y="14" width="7" height="7" rx="1" />
      <rect x="14" y="14" width="3" height="3" />
      <rect x="19" y="14" width="2" height="2" />
      <rect x="14" y="19" width="2" height="2" />
      <rect x="18" y="18" width="3" height="3" />
    </svg>
  )
}

function EmployeesIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={active ? 2.2 : 1.8} strokeLinecap="round">
      <circle cx="9" cy="7" r="3.5" />
      <path d="M3 20c0-3.314 2.686-6 6-6s6 2.686 6 6" />
      <circle cx="17.5" cy="8" r="2.5" />
      <path d="M21 20c0-2.485-1.567-4.6-3.5-5.5" />
    </svg>
  )
}

function PromosIcon({ active }: { active: boolean }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={active ? 2.2 : 1.8} strokeLinecap="round">
      <polygon points="12,2 15.09,8.26 22,9.27 17,14.14 18.18,21.02 12,17.77 5.82,21.02 7,14.14 2,9.27 8.91,8.26" />
    </svg>
  )
}

export default function App() {
  const [tab, setTab] = useState<Tab>('tables')
  const [dark, setDark] = useState(false)
  const [settings, setSettings] = useState(false)

  const today = new Date().toLocaleDateString('es-MX', { weekday: 'long', day: 'numeric', month: 'long' })
  const todayCap = today.charAt(0).toUpperCase() + today.slice(1)

  return (
    <div
      className={dark ? 'dark' : ''}
      style={{ minHeight: '100vh', backgroundColor: 'var(--background)', fontFamily: 'Outfit, sans-serif' }}
    >
      {/* Top Bar */}
      <header
        className="flex items-center justify-between px-5 pt-12 pb-4"
        style={{ backgroundColor: 'var(--background)' }}
      >
        <div>
          <p className="text-xs font-medium" style={{ color: 'var(--muted-foreground)' }}>{todayCap}</p>
          <p className="text-base font-semibold mt-0.5" style={{ color: 'var(--foreground)' }}>Hola, Lucía 👋</p>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setDark(d => !d)}
            className="w-9 h-9 rounded-full flex items-center justify-center transition-all active:scale-90"
            style={{ backgroundColor: 'var(--card)', boxShadow: '0 1px 6px rgba(0,0,0,0.08)' }}
          >
            <span className="text-base">{dark ? '☀️' : '🌙'}</span>
          </button>
          <button
            onClick={() => setSettings(true)}
            className="w-9 h-9 rounded-full flex items-center justify-center transition-all active:scale-90"
            style={{ backgroundColor: 'var(--card)', boxShadow: '0 1px 6px rgba(0,0,0,0.08)' }}
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" style={{ color: 'var(--foreground)' }}>
              <circle cx="12" cy="12" r="3" />
              <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" />
            </svg>
          </button>
        </div>
      </header>

      {/* Screen content */}
      <main className="pb-32 overflow-y-auto" style={{ minHeight: 'calc(100vh - 80px)' }}>
        {tab === 'tables' && <TablesScreen />}
        {tab === 'menu' && <MenuScreen />}
        {tab === 'qr' && <QRScreen />}
        {tab === 'employees' && <EmployeesScreen />}
        {tab === 'promotions' && <PromosScreen />}
      </main>

      {/* Floating Bottom Nav */}
      <nav
        className="fixed bottom-4 left-3 right-3 z-20 flex items-center justify-around px-3"
        style={{
          backgroundColor: dark ? 'rgba(26, 35, 55, 0.96)' : 'rgba(255,255,255,0.96)',
          borderRadius: 28,
          height: 68,
          boxShadow: dark
            ? '0 8px 32px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.06)'
            : '0 8px 32px rgba(0,0,0,0.14), 0 0 0 1px rgba(0,0,0,0.04)',
          backdropFilter: 'blur(12px)',
        }}
      >
        {NAV_TABS.map(({ id, icon: Icon, label, center }) => {
          const active = tab === id
          if (center) {
            return (
              <button
                key={id}
                onClick={() => setTab(id)}
                className="relative flex flex-col items-center justify-center -mt-6 transition-all active:scale-90"
              >
                <div
                  className="w-14 h-14 rounded-full flex items-center justify-center shadow-lg"
                  style={{
                    backgroundColor: active ? 'var(--accent)' : 'var(--primary)',
                    boxShadow: active
                      ? '0 4px 16px rgba(245,166,35,0.5)'
                      : '0 4px 16px rgba(217,79,61,0.4)',
                    color: '#fff',
                  }}
                >
                  <Icon active={active} />
                </div>
                <span className="text-xs mt-1 font-medium" style={{ color: active ? 'var(--accent)' : 'var(--muted-foreground)' }}>
                  {label}
                </span>
              </button>
            )
          }
          return (
            <button
              key={id}
              onClick={() => setTab(id)}
              className="flex flex-col items-center gap-1 transition-all active:scale-90 px-2"
            >
              <div style={{ color: active ? 'var(--primary)' : 'var(--muted-foreground)' }}>
                <Icon active={active} />
              </div>
              <span
                className="text-xs font-medium"
                style={{ color: active ? 'var(--primary)' : 'var(--muted-foreground)' }}
              >
                {label}
              </span>
            </button>
          )
        })}
      </nav>

      {settings && <SettingsSheet onClose={() => setSettings(false)} />}
    </div>
  )
}