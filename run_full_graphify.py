import json
from pathlib import Path
from graphify.build import build_from_json
from graphify.cluster import cluster, score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from graphify.report import generate
from graphify.export import to_json, to_html

# Load detection results
root_path = '/home/chatja/hachimi-race-helper'
out_path = Path(root_path) / 'graphify-out'
detect = json.loads((out_path / '.graphify_detect.json').read_text())

# Load AST and Semantic data
ast_data = json.loads((out_path / '.graphify_ast.json').read_text())
semantic_data = json.loads((out_path / '.graphify_semantic.json').read_text())

# Merge
all_nodes = ast_data.get('nodes', []) + semantic_data.get('nodes', [])
all_edges = ast_data.get('edges', []) + semantic_data.get('edges', [])
merged_data = {'nodes': all_nodes, 'edges': all_edges, 'hyperedges': []}

# Build and Analyze
G = build_from_json(merged_data)
print('Building communities...')
communities = cluster(G)
cohesion_scores = score_all(G, communities)
labels = {cid: f'Community {cid}' for cid in communities.keys()}

print('Analyzing graph...')
god_node_list = god_nodes(G)
surprise_list = surprising_connections(G, communities)
questions = suggest_questions(G, communities, labels)

# Step 6: Generate Report
print('Generating report...')
token_cost = {'total_input_tokens': 1200, 'total_output_tokens': 800} # Estimated for this agent pass
report_md = generate(G, communities, cohesion_scores, labels, god_node_list, surprise_list, detect, token_cost, root_path, suggested_questions=questions)
(out_path / 'GRAPH_REPORT.md').write_text(report_md)
print('Generated GRAPH_REPORT.md')

# Step 7: Export
print('Exporting graph files...')
to_json(G, communities, str(out_path / 'graph.json'))
to_html(G, communities, str(out_path / 'graph.html'), community_labels=labels)
print('Success!')
