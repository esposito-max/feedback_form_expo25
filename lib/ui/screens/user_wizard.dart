import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../../providers/app_state.dart';
import '../../utils/formatters.dart';
import '../shared/components.dart';

// --- 1. HomePage (Unchanged) ---
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

// --- 2. Feedback Expo (Unchanged) ---
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
          buildQuestion("Conte sobre sua experiência na Expo? *"),
          TextField(
            controller: _opiniaoController,
            maxLines: 2,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => appState.updateDraft((d) => d.opiniaoExpo = val),
          ),
          const SizedBox(height: 32),
          buildQuestion("A ExpoTEA foi satisfatória em relação às suas expectativas de Networking, oportunidades de negócios e vendas? *"),
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

// --- 3. Feedback Representante (Unchanged) ---
class FeedbackRepresentantePage extends StatefulWidget {
  const FeedbackRepresentantePage({super.key});
  @override
  State<FeedbackRepresentantePage> createState() => _FeedbackRepresentantePageState();
}

class _FeedbackRepresentantePageState extends State<FeedbackRepresentantePage> {
  late TextEditingController _obsController;
  late TextEditingController _reasonController;

  final List<Map<String, String>> allRepresentatives = const [
    {'name': 'Cristina Gouveia', 'phone': '(11) 94763-3153'},
    {'name': 'Dani Esposito', 'phone': '(11) 95285-8703'},
    {'name': 'Flavia Carvalho', 'phone': '(21) 99409-7143'},
    {'name': 'Jacson Marçal', 'phone': '(62) 98151-1131'},
    {'name': 'Marcelo', 'phone': '(11) 94707-5133'},
    {'name': 'Tatiana Dias', 'phone': '(11) 94899-9020'},
    {'name': 'Tatiana Silva', 'phone': '(11) 95910-2731'},
    {'name': 'Viviane Mendes', 'phone': '(11) 97759-0932'},
  ];

  @override
  void initState() {
    super.initState();
    final draft = AppStateProvider.read(context).currentDraft;
    _obsController = TextEditingController(text: draft.obsEquipe);
    _reasonController = TextEditingController(text: draft.motivoNaoFuturoRep);
  }

  @override
  void dispose() {
    _obsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _showContactDialog(String newRepName, String newRepPhone, String oldRepName, String oldRepPhone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A2458),
          title: Text("Contatar $newRepName", style: const TextStyle(color: Colors.white)),
          content: const Text(
            "Por favor, realize as duas ações abaixo para concluir a troca de representante.",
            style: TextStyle(color: Colors.white70),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: Text("1. Avisar $oldRepName (Encerrar)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.8),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    _launchWhatsApp(oldRepPhone, 
                      message: "Olá $oldRepName, agradeço o atendimento, mas decidi seguir com outro representante. Obrigado!"
                    );
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: Text("2. Falar com $newRepName (Iniciar)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    _launchWhatsApp(newRepPhone, 
                      message: "Olá $newRepName, eu era acompanhado por $oldRepName mas por diversos motivos decidi seguir com você como representante."
                    );
                  },
                ),
                TextButton(
                  child: const Text("Fechar", style: TextStyle(color: Colors.white54)),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            )
          ],
        );
      }
    );
  }

  void _launchWhatsApp(String phoneDisplay, {required String message}) async {
    final cleanPhone = '55' + phoneDisplay.replaceAll(RegExp(r'\D'), '');
    final encodedMessage = Uri.encodeComponent(message);
    final urlString = "https://api.whatsapp.com/send/?phone=$cleanPhone&text=$encodedMessage&type=phone_number&app_absent=0";
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Não foi possível abrir o WhatsApp")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final draft = appState.currentDraft;
    final bool isRepSelectionValid = draft.futuroRep != 'Não' || draft.novoRepSelecionado.isNotEmpty;
    final isValid = draft.suporteRep.isNotEmpty && draft.futuroRep.isNotEmpty && isRepSelectionValid;

    final currentRepObj = allRepresentatives.firstWhere(
      (c) => c['phone'] == draft.telefoneRep,
      orElse: () => {'name': 'Desconhecido', 'phone': draft.telefoneRep},
    );
    final currentRepName = currentRepObj['name']!;
    final currentRepPhone = currentRepObj['phone']!;

    final otherContacts = allRepresentatives
        .where((c) => c['phone'] != draft.telefoneRep)
        .toList();

    return FormSectionLayout(
      title: "Feedback Representante",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildQuestion("Seu representante lhe forneceu o suporte e acompanhamento necessários para que sua participação na expo fosse satisfatória? *"),
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
          
          if (draft.futuroRep == 'Não') ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF00CCFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00CCFF).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                      children: [
                        const TextSpan(text: "Como você optou por não continuar com o atual ("),
                        TextSpan(
                          text: "$currentRepName - $currentRepPhone", 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                        const TextSpan(text: "), por favor selecione um novo representante abaixo:"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...otherContacts.map((contact) {
                    final isSelected = draft.novoRepSelecionado == contact['name'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ElevatedButton.icon(
                        icon: Icon(
                          isSelected ? Icons.check_circle : Icons.person_add, 
                          color: isSelected ? Colors.white : Colors.white70
                        ),
                        label: Text(
                          "${contact['name']} - ${contact['phone']}",
                          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? const Color(0xFF25D366) : Colors.white.withOpacity(0.1),
                          foregroundColor: Colors.white,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          side: isSelected ? const BorderSide(color: Colors.white, width: 2) : null,
                        ),
                        onPressed: () {
                          appState.updateDraft((d) => d.novoRepSelecionado = contact['name']!);
                          _showContactDialog(
                            contact['name']!, 
                            contact['phone']!,
                            currentRepName,
                            currentRepPhone
                          );
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            buildQuestion("Considerações"),
            TextField(
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: "Digite aqui o motivo...",
              ),
              onChanged: (val) => appState.updateDraft((d) => d.motivoNaoFuturoRep = val),
            ),
          ],
          const Divider(height: 48, color: Colors.white24),
          buildQuestion("Exceto seu representante. Você tem alguma observação sobre o restante da equipe organizadora?"),
          TextField(
            maxLines: 3,
            textDirection: TextDirection.ltr,
            style: const TextStyle(color: Colors.white),
            controller: _obsController,
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

// --- 4. Feedback Montagem (Unchanged) ---
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

// --- 5. Feedback Geral (SUBMITS DATA HERE) ---
class FeedbackGeralPage extends StatefulWidget {
  const FeedbackGeralPage({super.key});
  @override
  State<FeedbackGeralPage> createState() => _FeedbackGeralPageState();
}

class _FeedbackGeralPageState extends State<FeedbackGeralPage> {
  late TextEditingController _considFestaController;
  late TextEditingController _ceoMsgController;

  @override
  void initState() {
    super.initState();
    final draft = AppStateProvider.read(context).currentDraft;
    _considFestaController = TextEditingController(text: draft.considFesta);
    _ceoMsgController = TextEditingController(text: draft.msgCeo);
  }

  @override
  void dispose() {
    _considFestaController.dispose();
    _ceoMsgController.dispose();
    super.dispose();
  }

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
          
          const Divider(height: 48, color: Colors.white24),
          
          buildQuestion("Você participou da festa de encerramento?"),
          buildRadioGroup(
            options: ["Sim", "Não"],
            selected: draft.foiFesta,
            onSelect: (val) => appState.updateDraft((d) => d.foiFesta = val),
          ),
          const SizedBox(height: 24),
          
          buildQuestion("Possui alguma consideração sobre a festa?"),
          TextField(
            controller: _considFestaController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "O que achou da comida, música, ambiente...",
            ),
            onChanged: (val) => appState.updateDraft((d) => d.considFesta = val),
          ),
          
          const SizedBox(height: 32),
          
          buildQuestion("Gostaria de deixar alguma mensagem para o CEO e sua equipe?"),
          TextField(
            controller: _ceoMsgController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Escreva sua mensagem aqui...",
            ),
            onChanged: (val) => appState.updateDraft((d) => d.msgCeo = val),
          ),
        ],
      ),
      onBack: () => appState.setSection(3),
      isNextEnabled: isValid,
      nextLabel: "Finalizar e enviar",
      // UPDATED: Submit Logic Moved Here
      onNext: () async {
        try {
          // 1. Submit Data
          await appState.submitForm();
          
          // 2. Success Message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Resposta enviada com sucesso!"),
                backgroundColor: Color(0xFF99CC33),
              ),
            );
          }
          
          // 3. Navigate to Outro Page (Manually)
          appState.setSection(5);
          
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro ao enviar: $e"), backgroundColor: Colors.red),
            );
          }
        }
      },
    );
  }
}

// --- 6. Outro Page (RESETS DATA HERE) ---
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
      nextLabel: "Nova Resposta",
      // UPDATED: Reset Logic Moved Here
      onNext: () {
        appState.resetForm();
      },
    );
  }
}