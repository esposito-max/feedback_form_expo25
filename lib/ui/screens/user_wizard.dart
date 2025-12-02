import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';
import '../shared/components.dart';

// --- 1. HomePage ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _cpfController;
  late TextEditingController _phoneController;
  final FocusNode _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize controllers ONCE with data from state
    final draft = AppStateProvider.read(context).currentDraft;
    _cpfController = TextEditingController(text: draft.cpfCnpj);
    _phoneController = TextEditingController(text: draft.telefoneRep);
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final draft = appState.currentDraft;
    final isValid = draft.cpfCnpj.length >= 14 && draft.telefoneRep.length >= 14;

    return FormSectionLayout(
      content: Column(
        children: [
          const Text(
            "Bem-vindo à ExpoTEA 2025",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF00CCFF),
              fontSize: 26, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Este formulário será utilizado para melhorar a sua e a experiência de todos nas próximas edições.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.6, color: Colors.white70),
          ),
          const SizedBox(height: 40),
          
          buildQuestion("Qual o CPF/CNPJ da empresa a qual você representa? *"),
          TextField(
            controller: _cpfController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(14),
              CpfCnpjFormatter(),
            ],
            decoration: const InputDecoration(
              hintText: "00.000.000/0000-00",
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            onChanged: (val) => appState.updateDraft((d) => d.cpfCnpj = val),
          ),
          
          const SizedBox(height: 32),
          
          buildQuestion("Qual o numero de telefone do representante que lhe acompanhou? *"),
          TextField(
            controller: _phoneController,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
              PhoneFormatter(),
            ],
            decoration: const InputDecoration(
              hintText: "(XX) XXXXX-XXXX",
              prefixIcon: Icon(Icons.phone),
            ),
            onChanged: (val) => appState.updateDraft((d) => d.telefoneRep = val),
          ),
        ],
      ),
      isNextEnabled: isValid,
      onNext: () => appState.setSection(1),
    );
  }
}

// --- 2. Feedback Expo (Converted to Stateful) ---
class FeedbackExpoPage extends StatefulWidget {
  const FeedbackExpoPage({super.key});

  @override
  State<FeedbackExpoPage> createState() => _FeedbackExpoPageState();
}

class _FeedbackExpoPageState extends State<FeedbackExpoPage> {
  late TextEditingController _opiniaoController;
  late TextEditingController _expectativasController;

  @override
  void initState() {
    super.initState();
    final draft = AppStateProvider.read(context).currentDraft;
    _opiniaoController = TextEditingController(text: draft.opiniaoExpo);
    _expectativasController = TextEditingController(text: draft.expectativasExpo);
  }

  @override
  void dispose() {
    _opiniaoController.dispose();
    _expectativasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final draft = appState.currentDraft;
    final isValid = draft.opiniaoExpo.isNotEmpty && draft.expectativasExpo.isNotEmpty;

    return FormSectionLayout(
      title: "Feedback Expo",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildQuestion("Qual sua opinião sobre a sua experiência na Expo? *"),
          TextField(
            controller: _opiniaoController,
            maxLines: 2,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => appState.updateDraft((d) => d.opiniaoExpo = val),
          ),
          const SizedBox(height: 32),
          buildQuestion("A Expo foi satisfatória em relação às suas expectativas de Networking, oportunidade de negócios, e volume de vendas? *"),
          TextField(
            controller: _expectativasController,
            maxLines: 4,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => appState.updateDraft((d) => d.expectativasExpo = val),
          ),
        ],
      ),
      onBack: () => appState.setSection(0),
      isNextEnabled: isValid,
      onNext: () => appState.setSection(2),
    );
  }
}

// --- 3. Feedback Representante (Converted to Stateful) ---
class FeedbackRepresentantePage extends StatefulWidget {
  const FeedbackRepresentantePage({super.key});

  @override
  State<FeedbackRepresentantePage> createState() => _FeedbackRepresentantePageState();
}

class _FeedbackRepresentantePageState extends State<FeedbackRepresentantePage> {
  late TextEditingController _obsController;

  final List<Map<String, String>> allRepresentatives = const [
    {'name': 'Carlos Silva', 'phone': '(11) 99999-0001'},
    {'name': 'Ana Souza', 'phone': '(11) 98888-0002'},
    {'name': 'João Oliveira', 'phone': '(11) 97777-0003'},
    {'name': 'Mariana Santos', 'phone': '(21) 96666-0004'},
  ];

  @override
  void initState() {
    super.initState();
    final draft = AppStateProvider.read(context).currentDraft;
    _obsController = TextEditingController(text: draft.obsEquipe);
  }

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final draft = appState.currentDraft;
    final isValid = draft.suporteRep.isNotEmpty && draft.futuroRep.isNotEmpty;

    final currentRepObj = allRepresentatives.firstWhere(
      (c) => c['phone'] == draft.telefoneRep,
      orElse: () => {'name': 'Desconhecido', 'phone': draft.telefoneRep},
    );
    final currentRepName = currentRepObj['name'];

    final otherContacts = allRepresentatives
        .where((c) => c['phone'] != draft.telefoneRep)
        .toList();

    String contactsListMarkdown = otherContacts.isEmpty
        ? "Nenhum outro contato disponível."
        : otherContacts.map((c) => "- ${c['name']}: ${c['phone']}").join("\n");

    return FormSectionLayout(
      title: "Feedback Representante",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildQuestion("Seu representante lhe forneceu o suporte e informações necessárias para que sua assinatura de contrato e estadia na expo fossem satisfatórias? *"),
          buildRadioGroup(
            options: ["Sim", "Não", "Poderia ter sido melhor"],
            selected: draft.suporteRep,
            onSelect: (val) => appState.updateDraft((d) => d.suporteRep = val),
          ),
          const Divider(height: 48, color: Colors.white24),
          buildQuestion("Em negociações futuras você gostaria de realiza-las com o mesmo representante? *"),
           buildRadioGroup(
            options: ["Sim", "Não"],
            selected: draft.futuroRep,
            onSelect: (val) => appState.updateDraft((d) => d.futuroRep = val),
          ),
          const SizedBox(height: 32),
          
          if (draft.futuroRep == 'Não') 
            DynamicInformativeText(
              data: draft,
              template: 
                "### Outros Representantes Disponíveis\n"
                "Como você optou por não continuar com o atual (**$currentRepName - {telefoneRep}**), aqui estão outras opções:\n\n"
                "$contactsListMarkdown", 
            ),
          
          const Divider(height: 48, color: Colors.white24),
          buildQuestion("Exceto seu representante. Você tem alguma observação sobre o restante da equipe organizadora?"),
          TextField(
            controller: _obsController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => appState.updateDraft((d) => d.obsEquipe = val),
          ),
        ],
      ),
      onBack: () => appState.setSection(1),
      isNextEnabled: isValid,
      onNext: () => appState.setSection(3),
    );
  }
}

// --- 4. Feedback Montagem (Converted to Stateful) ---
class FeedbackMontagemPage extends StatefulWidget {
  const FeedbackMontagemPage({super.key});

  @override
  State<FeedbackMontagemPage> createState() => _FeedbackMontagemPageState();
}

class _FeedbackMontagemPageState extends State<FeedbackMontagemPage> {
  late TextEditingController _obsController;

  @override
  void initState() {
    super.initState();
    final draft = AppStateProvider.read(context).currentDraft;
    _obsController = TextEditingController(text: draft.obsMontagem);
  }

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final draft = appState.currentDraft;
    final isValid = draft.montagemSatisfatoria.isNotEmpty;

    return FormSectionLayout(
      title: "Feedback Montagem",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildQuestion("A montagem do seu estande foi satisfatória? *"),
          buildRadioGroup(
            options: ["Sim", "Não"],
            selected: draft.montagemSatisfatoria,
            onSelect: (val) => appState.updateDraft((d) => d.montagemSatisfatoria = val),
          ),
          const Divider(height: 48, color: Colors.white24),
          buildQuestion("Possui alguma observação sobre a montagem do seu estande?"),
          TextField(
            controller: _obsController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => appState.updateDraft((d) => d.obsMontagem = val),
          ),
        ],
      ),
      onBack: () => appState.setSection(2),
      isNextEnabled: isValid,
      onNext: () => appState.setSection(4),
    );
  }
}

// --- 5. Feedback Geral (Remains Stateless - No TextFields) ---
class FeedbackGeralPage extends StatelessWidget {
  const FeedbackGeralPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final draft = appState.currentDraft;
    final isValid = draft.recomenda.isNotEmpty;

    return FormSectionLayout(
      title: "Feedback Geral",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildQuestion("Você recomendaria a ExpoTEA para outras empresas como um bom evento? *"),
          buildRadioGroup(
            options: ["Sim", "Não"],
            selected: draft.recomenda,
            onSelect: (val) => appState.updateDraft((d) => d.recomenda = val),
          ),
        ],
      ),
      onBack: () => appState.setSection(3),
      isNextEnabled: isValid,
      onNext: () => appState.setSection(5),
    );
  }
}

// --- 6. Outro Page (Remains Stateless) ---
class OutroPage extends StatelessWidget {
  const OutroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.read(context);

    return FormSectionLayout(
      title: "Obrigado!",
      content: Column(
        children: const [
          Icon(Icons.check_circle_outline, size: 100, color: Color(0xFF99CC33)), // Verde Limão
          SizedBox(height: 24),
          Text(
            "Muito obrigado pela Resposta.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            "Suas respostas foram registradas com sucesso.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
      onBack: null, 
      nextLabel: "Finalizar / Nova Resposta",
      onNext: () async {
        try {
          await appState.submitForm();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Resposta enviada para a nuvem!"),
                backgroundColor: Color(0xFF99CC33),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
            );
          }
        }
      },
    );
  }
}