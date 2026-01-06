extends RigidBody2D

# ===== VARIÁVEIS DE ESTADO =====
# Indica se o mouse está sobre o pássaro (dentro da área clicável)
var mouse_on_bird: bool = false

# Indica se o pássaro está sendo segurado/arrastado pelo jogador
var bird_held: bool = false

# Indica se o pássaro já foi lançado (para evitar múltiplos lançamentos)
var bird_shot: bool = false

# Guarda a posição inicial do estilingue (ponto de referência)
var start_point: Vector2

# Contador de tempo para destruir o pássaro após ficar parado
var timer: float = 0.0

# ===== CONSTANTES DE CONFIGURAÇÃO =====
# Raio máximo que o pássaro pode ser puxado (distância do estilingue)
const RADIUS = 85

# Multiplicador de força aplicada ao soltar o pássaro
# Quanto maior, mais forte será o lançamento
const FORCE = 12

# ===== REFERÊNCIAS DE CENA =====
# Referência ao ponto do estilingue (Marker2D) definido no editor
@export var sling_point: Marker2D = null

# Referência ao visual do estilingue (para desenhar as cordas)
@export var sling_shot: Node2D = null

# ===== INICIALIZAÇÃO =====
func _ready() -> void:
	# Define este pássaro como alvo do estilingue (para desenhar as cordas conectadas)
	sling_shot.target = self
	# Salva a posição do estilingue como ponto de partida
	start_point = sling_point.position
	# Posiciona o pássaro no estilingue ao iniciar
	position = start_point

# ===== LOOP PRINCIPAL =====
# Chamado a cada frame (normalmente 60x por segundo)
func _process(delta: float) -> void:
	# --- SISTEMA DE AUTO-DESTRUIÇÃO APÓS PARAR ---
	# Verifica se o pássaro está quase parado (velocidade < 10) E já foi lançado
	if linear_velocity.length() < 10 and bird_shot:
		# Incrementa o contador de tempo com o tempo do frame
		timer = timer + delta

		# Se ficou parado por mais de 2 segundos, destrói e spawna novo pássaro
		if timer > 2:
			kill()

	# --- SISTEMA DE LIMITE DE TELA ---
	# Debug: imprime a posição Y no console (pode remover depois)
	print(position.y)
	# Se o pássaro caiu abaixo do limite da tela (Y > 400), destrói
	if position.y > 400:
		kill()

# ===== DETECÇÃO DE MOUSE =====
# Chamado quando o mouse ENTRA na área do pássaro
func _on_mouse_entered() -> void:
	mouse_on_bird = true

# Chamado quando o mouse SAI da área do pássaro
func _on_mouse_exited() -> void:
	mouse_on_bird = false

# ===== SISTEMA DE INPUT =====
# Chamado sempre que há um evento de entrada (clique, tecla, etc.)
func _input(_event):
	# Se o pássaro já foi lançado, ignora todos os inputs
	# Isso impede que o jogador tente arrastar o pássaro depois de lançar
	if bird_shot:
		return

	# --- PEGAR O PÁSSARO ---
	# Verifica se o jogador clicou (ação "drag") E o mouse está sobre o pássaro
	if Input.is_action_just_pressed("drag") and mouse_on_bird:
		bird_held = true # Marca que está segurando o pássaro

	# --- SOLTAR O PÁSSARO ---
	# Verifica se o jogador soltou o clique E estava segurando o pássaro
	if Input.is_action_just_released("drag") and bird_held:
		bird_held = false # Marca que não está mais segurando
		freeze = false # Reativa a física do pássaro (desabilita o congelamento)
		bird_shot = true # Marca que o pássaro foi lançado (impede novos arrastos)

		# Calcula a força de lançamento baseada na distância puxada
		# (posição atual - posição inicial) * -FORCE
		# O sinal negativo inverte a direção: puxa para trás = lança para frente
		linear_velocity = (position - start_point) * -FORCE

		# Remove a referência do estilingue (para não desenhar mais as cordas)
		sling_shot.target = null

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

# ===== SISTEMA DE RESPAWN =====
# Destrói o pássaro atual e cria um novo no estilingue
func kill():
	# Remove este pássaro da cena (marca para deletar no fim do frame)
	queue_free()

	# Carrega a cena do pássaro e cria uma nova instância
	var new_bird = load("res://Entities/bird.tscn").instantiate()

	# Passa as referências do estilingue para o novo pássaro
	# Assim ele sabe onde se posicionar e como desenhar as cordas
	new_bird.sling_point = sling_point
	new_bird.sling_shot = sling_shot

	# Adiciona o novo pássaro como filho do mesmo nó pai (a cena principal)
	get_parent().add_child(new_bird)
