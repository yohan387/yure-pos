import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:todouapp/core/widgets/custom_snackbar.dart';
import 'package:todouapp/features/profil/presentation/bloc/profil_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/initials.dart';
import '../../../../core/utils/secure_storage.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfilBloc>().add(LoadProfilEvent());
    getStripeConnectedTerminal();
  }

  String terminal = '';
  getStripeConnectedTerminal() async {
    final secureStorage = SecureStorageService();
    final ter = await secureStorage.getStripeConnectedTerminal();
    setState(() {
      terminal = "$ter";
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text("Mon Profil"),
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocListener<ProfilBloc, ProfilState>(
        listener: (context, state) {
          if (state.status == ProfilStatus.failure) {
            CustomSnackbar.showError(
                context, state.errorMessage ?? 'Unknown error');
          }
        },
        child: BlocBuilder<ProfilBloc, ProfilState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 50,
                        child: Center(
                          child: Text(
                            Initials.initials(
                              state.profil?.firstName ?? '',
                              state.profil?.lastName ?? '',
                            ),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${state.profil?.firstName} ${state.profil?.lastName}",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 375,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Icon(
                                  Icons.business,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "Business",
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            const Spacer(),
                            SizedBox(
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Text(
                                  state.profil?.businessType ?? '',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 64,
                        width: 375,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Icon(
                                  Icons.business,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "Nom",
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            const Spacer(),
                            SizedBox(
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Text(
                                  state.profil?.businessName ?? '',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 64,
                        width: 375,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Icon(
                                  Icons.date_range,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "Date de création",
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            const Spacer(),
                            SizedBox(
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Text(
                                  state.profil?.createdAt != null
                                      ? dateFormat
                                          .format(state.profil!.createdAt)
                                      : 'N/A',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 64,
                        width: 375,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Icon(
                                  Icons.email,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "Email",
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            const Spacer(),
                            SizedBox(
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Text(
                                  state.profil?.email ?? 'N/A',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 64,
                        width: 375,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "Téléphone",
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            const Spacer(),
                            SizedBox(
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Text(
                                  state.profil?.phoneNumbers.isNotEmpty ?? false
                                      ? state.profil!.phoneNumbers.first
                                      : 'N/A',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      if (terminal.isNotEmpty)
                        Column(
                          children: [
                            Text(
                              'Terminal Connecté',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Lottie.asset(
                              'assets/animations/connected.json',
                              fit: BoxFit.fill,
                              height: 40,
                            ),
                            Text(
                              terminal,
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor),
                            )
                          ],
                        ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
