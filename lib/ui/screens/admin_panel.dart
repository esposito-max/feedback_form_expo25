import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/app_state.dart';
import '../../models/feedback_form.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Acesso Restrito")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 64, color: Colors.indigo),
              const SizedBox(height: 24),
              const Text("Credenciais de Admin"),
              const SizedBox(height: 16),
              
              TextField(
                controller: _emailController,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _passController,
                obscureText: true,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: "Senha",
                  errorText: error.isEmpty ? null : error,
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () async {
                  final success = await AppStateProvider.read(context).loginAdmin(
                    _emailController.text, 
                    _passController.text
                  );
                  
                  if (success && mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminDashboard()),
                    );
                  } else {
                    if (mounted) {
                      setState(() => error = "Credenciais Inválidas");
                    }
                  }
                },
                child: const Text("Entrar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Respostas Recebidas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppStateProvider.read(context).logoutAdmin();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getSubmissionsCollection().orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
             return Center(child: Text("Erro: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return const Center(child: Text("Nenhuma resposta ainda.", style: TextStyle(color: Colors.black54)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final item = FeedbackForm.fromMap(docs[index].id, data);
              return DataCard(data: item);
            },
          );
        },
      ),
    );
  }
}

class DataCard extends StatelessWidget {
  final FeedbackForm data;
  const DataCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Determine what to show for "Future Representative"
    String futuroRepDisplay;
    if (data.futuroRep == 'Não') {
      futuroRepDisplay = data.novoRepSelecionado.isNotEmpty 
          ? "Trocar por: ${data.novoRepSelecionado}" 
          : "Trocar (Não selecionou novo)";
    } else {
      futuroRepDisplay = "Manter o mesmo";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          "Empresa: ${data.cpfCnpj}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Text(
          "Recomendaria Evento: ${data.recomenda}",
          style: TextStyle(
            color: data.recomenda == 'Sim' ? Colors.green[700] : Colors.red[700],
            fontWeight: FontWeight.w500
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          _sectionHeader("Contato"),
          _row("Telefone Rep. Atual", data.telefoneRep),
          
          const Divider(),
          _sectionHeader("Sobre a Expo"),
          _row("Opinião Geral", data.opiniaoExpo),
          _row("Expectativas Atendidas?", data.expectativasExpo),
          
          const Divider(),
          _sectionHeader("Relacionamento com Representante"),
          _row("Avaliação do Suporte", data.suporteRep),
          _row("Próximo Representante", futuroRepDisplay),
          if (data.motivoNaoFuturoRep.isNotEmpty) 
            _row("Motivo da Troca", data.motivoNaoFuturoRep),
          if (data.obsEquipe.isNotEmpty) 
            _row("Observações da Equipe", data.obsEquipe),
          
          const Divider(),
          _sectionHeader("Estrutura"),
          _row("Montagem Satisfatória?", data.montagemSatisfatoria),
          if (data.obsMontagem.isNotEmpty) 
            _row("Obs. da Montagem", data.obsMontagem),

          const Divider(),
          _sectionHeader("Festa & Encerramento"),
          _row("Foi à Festa?", data.foiFesta.isEmpty ? "Não respondeu" : data.foiFesta),
          if (data.considFesta.isNotEmpty) 
            _row("Considerações Festa", data.considFesta),
          if (data.msgCeo.isNotEmpty) 
            _row("Mensagem ao CEO", data.msgCeo),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 12, 
          color: Colors.indigo,
          letterSpacing: 1.0
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140, // Fixed width for labels alignment
            child: Text(
              "$label:", 
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[700])
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value, 
              style: const TextStyle(fontSize: 14, color: Colors.black87)
            ),
          ),
        ],
      ),
    );
  }
}