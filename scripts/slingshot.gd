extends Sprite2D

# ===== VARIÁVEIS =====
# Referência ao pássaro que está conectado ao estilingue
# Quando null, as cordas ficam escondidas (nenhum pássaro no estilingue)
var target: RigidBody2D = null

# ===== REFERÊNCIAS DE NÓS FILHOS =====
# @onready significa que estas variáveis serão atribuídas quando o nó estiver pronto
# $LeftLine é atalho para get_node("LeftLine") - pega o nó filho chamado "LeftLine"

# Linha (Line2D) da corda esquerda do estilingue
@onready var left_line = $LeftLine

# Linha (Line2D) da corda direita do estilingue
@onready var right_line = $RightLine

# ===== LOOP PRINCIPAL =====
# Chamado a cada frame para atualizar a posição das cordas
func _process(_delta):
	# --- VERIFICAÇÃO DE ALVO ---
	# Se não há pássaro conectado ao estilingue
	if target == null:
		# Esconde ambas as cordas (não há nada para conectar)
		left_line.hide()
		right_line.hide()
	else:
		# --- ATUALIZAÇÃO DAS CORDAS ---
		# Há um pássaro, então mostra as cordas
		left_line.show()
		right_line.show()

		# Atualiza a posição do SEGUNDO ponto (índice 1) de cada linha
		# O primeiro ponto (índice 0) fica fixo no estilingue
		# O segundo ponto segue o pássaro

		# to_local() converte a posição global do pássaro para coordenadas locais da linha
		# Vector2(-22, 0) desloca para a ESQUERDA do centro do pássaro
		left_line.set_point_position(1, left_line.to_local(target.position) + Vector2(-22, 0))

		# Vector2(22, 0) desloca para a DIREITA do centro do pássaro
		right_line.set_point_position(1, right_line.to_local(target.position) + Vector2(22, 0))
