import 'package:flutter/material.dart';
import 'package:bettingapp/widgets/common/modal.dart';

class TestModalScreen extends StatefulWidget {
  const TestModalScreen({super.key});

  @override
  State<TestModalScreen> createState() => _TestModalScreenState();
}

class _TestModalScreenState extends State<TestModalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Modals'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Success Modals'),
            _buildButton(
              'Success Modal (Auto-dismiss)',
              () => Modal.showSuccessModal(
                title: 'Success',
                message: 'Operation completed successfully with auto-dismiss.',
                showButton: false,
              ),
            ),
            _buildButton(
              'Success Modal (With Button)',
              () => Modal.showSuccessModal(
                title: 'Success',
                message: 'Operation completed successfully with button.',
                showButton: true,
                buttonText: 'Great!',
              ),
            ),
            
            _buildSectionTitle('Error Modals'),
            _buildButton(
              'Error Modal',
              () => Modal.showErrorModal(
                title: 'Error',
                message: 'Something went wrong. Please try again.',
              ),
            ),
            _buildButton(
              'Error Modal (Custom Button)',
              () => Modal.showErrorModal(
                title: 'Error',
                message: 'Something went wrong. Please try again later.',
                buttonText: 'Try Again',
              ),
            ),
            
            _buildSectionTitle('Confirmation Modals'),
            _buildButton(
              'Confirmation Modal',
              () => Modal.showConfirmationModal(
                title: 'Confirm Action',
                message: 'Are you sure you want to proceed with this action?',
                onConfirm: () {
                  Modal.showSuccessModal(
                    title: 'Confirmed',
                    message: 'Action confirmed successfully!',
                  );
                },
              ),
            ),
            _buildButton(
              'Dangerous Confirmation Modal',
              () => Modal.showConfirmationModal(
                title: 'Delete Item',
                message: 'Are you sure you want to delete this item? This action cannot be undone.',
                confirmText: 'Delete',
                isDangerousAction: true,
                onConfirm: () {
                  Modal.showSuccessModal(
                    title: 'Deleted',
                    message: 'Item deleted successfully!',
                  );
                },
              ),
            ),
            
            _buildSectionTitle('Info Modals'),
            _buildButton(
              'Info Modal',
              () => Modal.showInfoModal(
                title: 'Information',
                message: 'This is an informational message for the user.',
              ),
            ),
            _buildButton(
              'Info Modal (Custom Button)',
              () => Modal.showInfoModal(
                title: 'Information',
                message: 'This is an informational message with a custom button.',
                buttonText: 'Got it!',
              ),
            ),
            
            _buildSectionTitle('Progress Modals'),
            _buildButton(
              'Progress Modal',
              () {
                Modal.showProgressModal(
                  message: 'Loading data, please wait...',
                );
                
                // Simulate a delay and then close the modal
                Future.delayed(const Duration(seconds: 3), () {
                  Navigator.of(context).pop();
                  Modal.showSuccessModal(
                    title: 'Loaded',
                    message: 'Data loaded successfully!',
                  );
                });
              },
            ),
            
            _buildSectionTitle('No Internet Modal'),
            _buildButton(
              'No Internet Modal',
              () => Modal.showNoInternetModal(
                onRetry: () {
                  Navigator.of(context).pop();
                  Modal.showSuccessModal(
                    title: 'Connected',
                    message: 'Internet connection restored!',
                  );
                },
              ),
            ),
            
            _buildSectionTitle('Custom Modal'),
            _buildButton(
              'Custom Modal',
              () => Modal.showCustomModal(
                content: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.celebration,
                        size: 60,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Custom Content',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This is a completely custom modal with custom content and styling.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close Custom Modal'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
