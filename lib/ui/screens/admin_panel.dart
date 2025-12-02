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
        title: const Text("Respostas"),
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
      // FIX: Added SafeArea for mobile compliance (notches/dynamic islands)
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
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
              return const Center(child: Text("Nenhuma resposta ainda."));
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
      ),
    );
  }
}

class DataCard extends StatelessWidget {
  final FeedbackForm data;
  const DataCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          "ID: ${data.cpfCnpj}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Recomenda: ${data.recomenda}",
          style: TextStyle(
            color: data.recomenda == 'Sim' ? Colors.green : Colors.red,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          _row("Tel Rep", data.telefoneRep),
          _row("Opinião Expo", data.opiniaoExpo),
          _row("Expectativas", data.expectativasExpo),
          const Divider(),
          _row("Suporte Rep", data.suporteRep),
          _row("Futuro Rep", data.futuroRep),
          if (data.obsEquipe.isNotEmpty) _row("Obs Equipe", data.obsEquipe),
          const Divider(),
          _row("Montagem OK?", data.montagemSatisfatoria),
          if (data.obsMontagem.isNotEmpty) _row("Obs Montagem", data.obsMontagem),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}