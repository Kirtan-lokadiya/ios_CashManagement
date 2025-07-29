import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _loadingOpacityAnimation;

  bool _isInitializing = true;
  String _initializationStatus = 'Initializing...';
  double _initializationProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _loadingOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));

    _logoAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadingAnimationController.forward();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate database initialization
      await _updateProgress('Checking local storage...', 0.2);
      await Future.delayed(const Duration(milliseconds: 600));

      await _updateProgress('Loading language settings...', 0.4);
      await Future.delayed(const Duration(milliseconds: 500));

      await _updateProgress('Initializing notifications...', 0.6);
      await Future.delayed(const Duration(milliseconds: 400));

      await _updateProgress('Preparing transaction data...', 0.8);
      await Future.delayed(const Duration(milliseconds: 500));

      await _updateProgress('Ready!', 1.0);
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });

        // Navigate to dashboard after initialization
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        });
      }
    } catch (e) {
      // Handle initialization errors
      if (mounted) {
        setState(() {
          _initializationStatus = 'Initialization failed. Retrying...';
        });

        // Retry initialization after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _initializeApp();
          }
        });
      }
    }
  }

  Future<void> _updateProgress(String status, double progress) async {
    if (mounted) {
      setState(() {
        _initializationStatus = status;
        _initializationProgress = progress;
      });
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.lightTheme.primaryColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.primaryColor,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.lightTheme.primaryColor,
                  AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo section
                Expanded(
                  flex: 3,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _logoScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: _buildAppLogo(),
                        );
                      },
                    ),
                  ),
                ),

                // Loading section
                Expanded(
                  flex: 1,
                  child: AnimatedBuilder(
                    animation: _loadingOpacityAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _loadingOpacityAnimation.value,
                        child: _buildLoadingSection(),
                      );
                    },
                  ),
                ),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App icon/logo
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'account_balance_wallet',
              color: AppTheme.lightTheme.primaryColor,
              size: 12.w,
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // App name
        Text(
          'CashFlow Manager',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 1.h),

        // App tagline
        Text(
          'Track • Manage • Remind',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.8,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Loading indicator
        SizedBox(
          width: 60.w,
          child: LinearProgressIndicator(
            value: _initializationProgress,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white,
            ),
            minHeight: 0.8.h,
          ),
        ),

        SizedBox(height: 2.h),

        // Status text
        Text(
          _initializationStatus,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 1.h),

        // Progress percentage
        Text(
          '${(_initializationProgress * 100).toInt()}%',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
