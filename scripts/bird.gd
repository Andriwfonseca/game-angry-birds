extends RigidBody2D

# ===== VARIÁVEIS DE ESTADO =====
# Indica se o mouse está sobre o pássaro (dentro da área clicável)
var mouse_on_bird: bool = false

# Indica se o pássaro está sendo segurado/arrastado pelo jogador
var bird_held: bool = false

# Guarda a posição inicial do estilingue (ponto de referência)
var start_point: Vector2

# ===== CONSTANTES DE CONFIGURAÇÃO =====
# Raio máximo que o pássaro pode ser puxado (distância do estilingue)
const RADIUS = 85

# Multiplicador de força aplicada ao soltar o pássaro
# Quanto maior, mais forte será o lançamento
const FORCE = 12

# ===== REFERÊNCIAS DE CENA =====
# Referência ao ponto do estilingue (Marker2D) definido no editor
@export var sling_point: Marker2D = null

# ===== INICIALIZAÇÃO =====
func _ready() -> void:
	# Salva a posição do estilingue como ponto de partida
	start_point = sling_point.position
	# Posiciona o pássaro no estilingue ao iniciar
	position = start_point

# ===== DETECÇÃO DE MOUSE =====
# Chamado quando o mouse ENTRA na área do pássaro
func _on_mouse_entered() -> void:
	mouse_on_bird = true

# Chamado quando o mouse SAI da área do pássaro
func _on_mouse_exited() -> void:
	mouse_on_bird = false

# ===== SISTEMA DE INPUT =====
func _input(_event):
	# --- PEGAR O PÁSSARO ---
	# Verifica se o jogador clicou (ação "drag") E o mouse está sobre o pássaro
	if Input.is_action_just_pressed("drag") and mouse_on_bird:
		bird_held = true # Marca que está segurando o pássaro

	# --- SOLTAR O PÁSSARO ---
	# Verifica se o jogador soltou o clique E estava segurando o pássaro
	if Input.is_action_just_released("drag") and bird_held:
		bird_held = false # Marca que não está mais segurando
		freeze = false # Reativa a física do pássaro

		# Calcula a força de lançamento baseada na distância puxada
		# (posição atual - posição inicial) * -FORCE
		# O sinal negativo inverte a direção: puxa para trás = lança para frente
		linear_velocity = (position - start_point) * -FORCE

	# --- ARRASTAR O PÁSSARO ---
	# Enquanto o pássaro está sendo segurado
	if bird_held:
		# Verifica se o mouse está ALÉM do raio máximo do estilingue
		if start_point.distance_to(get_global_mouse_position()) > RADIUS:
			# Calcula a direção do estilingue até o mouse (vetor unitário)
			var direction = (get_global_mouse_position() - start_point).normalized()
			# Aplica o raio máximo nessa direção
			var offset = direction * RADIUS
			# Limita a posição do pássaro ao raio máximo
			position = start_point + offset
		else:
			# Se está dentro do raio, o pássaro segue o mouse livremente
			position = get_global_mouse_position()
