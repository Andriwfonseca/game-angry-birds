extends RigidBody2D

# ===== CONSTANTES DE CONFIGURAÇÃO =====
# Impacto necessário para "derrotar" a raposa (velocidade relativa mínima)
# Quanto maior o valor, mais forte precisa ser o impacto
const UNALIVE_IMPACT = 120

# ===== INICIALIZAÇÃO =====
func _ready() -> void:
	# CRÍTICO: Habilita o monitoramento de contatos
	# Sem isso, get_colliding_bodies() sempre retorna lista vazia!
	contact_monitor = true

	# Define quantos contatos simultâneos serão rastreados
	# Valor padrão é 0, precisamos de pelo menos 1
	max_contacts_reported = 10

# ===== PROCESSAMENTO DE FÍSICA =====
# Chamado a cada frame de física (normalmente 60x por segundo)
func _physics_process(_delta: float) -> void:
	# Verifica se há ALGUM corpo colidindo com a raposa
	# get_colliding_bodies() retorna TODOS os tipos de corpos em contato:
	# - RigidBody2D (objetos com física como o pássaro)
	# - StaticBody2D (objetos estáticos como paredes, chão)
	# - CharacterBody2D (personagens controláveis)
	# - Qualquer outro corpo físico
	# is_empty() retorna true se a lista está vazia (sem colisões)
	# not inverte: "se NÃO está vazio" = "se há colisões"
	if not get_colliding_bodies().is_empty():
		# Percorre CADA corpo que está colidindo com a raposa
		# IMPORTANTE: Isso NÃO filtra tipos, detecta QUALQUER corpo!
		for i in get_colliding_bodies():
			# Variável para guardar a velocidade do corpo que está colidindo
			var body_velocity: Vector2

			# Verifica APENAS para saber COMO pegar a velocidade:
			# - RigidBody2D TEM velocidade própria (pode estar se movendo)
			# - Outros corpos geralmente são estáticos (velocidade zero)
			if i is RigidBody2D:
				# Se for RigidBody2D, pega a velocidade real do objeto
				body_velocity = i.linear_velocity
			else:
				# Se for StaticBody2D, chão, parede, etc = não tem velocidade
				body_velocity = Vector2.ZERO

			# Calcula a DIFERENÇA de velocidade entre a raposa e o objeto
			# Isso determina a "força relativa" do impacto
			# Se a raposa está se movendo rápido E o objeto está parado = grande diferença
			var velocity_difference = linear_velocity - body_velocity

			# Verifica se a diferença de velocidade é MAIOR que o impacto necessário
			# length() retorna o tamanho/magnitude do vetor velocidade
			if velocity_difference.length() > UNALIVE_IMPACT:
				# Se o impacto for forte o suficiente, remove a raposa da cena
				# queue_free() marca o objeto para ser deletado no final do frame
				queue_free()
