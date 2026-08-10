import 'package:eschool/cubits/appSettingsCubit.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

/// Renders the policy/terms/about documents that arrive from the panel as
/// HTML.
///
/// The raw [HtmlWidget] output used to be dumped straight onto the page,
/// which read as one undifferentiated wall of text. This wraps it in a
/// document card with a titled header and styles the HTML itself — headings,
/// paragraph rhythm, list spacing, link colour — so panel-authored content
/// looks designed without the panel having to style anything.
class AppSettingsBlocBuilder extends StatelessWidget {
  final String appSettingsType;
  final bool useSchoolSettings;

  /// Shown in the document header card — pass the glyph that matches the
  /// document (shield for privacy, description for terms, info for about).
  final IconData headerIcon;

  /// Already-translated document title for the header card. When empty the
  /// header is omitted and only the styled content card renders.
  final String headerTitle;

  const AppSettingsBlocBuilder({
    Key? key,
    required this.appSettingsType,
    this.useSchoolSettings = false,
    this.headerIcon = Icons.description_outlined,
    this.headerTitle = "",
  }) : super(key: key);

  double _topPadding(BuildContext context) =>
      MediaQuery.of(context).size.height *
      (Utils.appBarSmallerHeightPercentage + 0.025);

  /// Document header: icon well, title and a short brand-coloured rule —
  /// the same visual language the dashboard section headers use.
  Widget _buildDocumentHeader(BuildContext context) {
    if (headerTitle.isEmpty) return const SizedBox();

    return Column(
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            headerIcon,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          headerTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 3,
          width: 34,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildContentCard(BuildContext context, String html) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardAll,
        boxShadow: AppShadows.card,
      ),
      child: HtmlWidget(
        html,
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.65,
            ),
        customStylesBuilder: (element) {
          switch (element.localName) {
            //Headings in the primary text colour so sections stand apart
            //from body copy.
            case 'h1':
            case 'h2':
              return {
                'color': '#1A1D29',
                'font-weight': '700',
                'font-size': '1.15em',
                'margin': '18px 0 8px 0',
              };
            case 'h3':
            case 'h4':
            case 'h5':
            case 'h6':
              return {
                'color': '#1A1D29',
                'font-weight': '600',
                'font-size': '1.05em',
                'margin': '14px 0 6px 0',
              };
            case 'p':
              return {'margin': '0 0 12px 0'};
            case 'li':
              return {'margin': '0 0 8px 0'};
            case 'ul':
            case 'ol':
              return {'margin': '0 0 12px 0', 'padding-left': '20px'};
            case 'a':
              return {
                'color': '#1B4DE4',
                'font-weight': '600',
                'text-decoration': 'none',
              };
            case 'strong':
            case 'b':
              return {'color': '#1A1D29', 'font-weight': '600'};
            case 'hr':
              return {'border-color': '#EEF1F6', 'margin': '16px 0'};
          }
          return null;
        },
      ),
    );
  }

  /// Skeleton that mirrors the loaded layout: header circle + title bar,
  /// then paragraph lines of varying width inside a card.
  Widget _buildLoadingSkeleton(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        top: _topPadding(context),
        left: AppSpacing.screenH,
        right: AppSpacing.screenH,
      ),
      child: Column(
        children: [
          if (headerTitle.isNotEmpty) ...[
            const ShimmerLoadingContainer(
              child: CustomShimmerContainer(
                height: 64,
                width: 64,
                borderRadius: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ShimmerLoadingContainer(
              child: CustomShimmerContainer(
                height: 18,
                width: width * 0.45,
                borderRadius: AppRadius.field,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.cardAll,
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(9, (i) {
                //Vary line lengths so the skeleton reads as paragraphs, with
                //a short line ending each "paragraph".
                final isParagraphEnd = i % 3 == 2;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isParagraphEnd ? AppSpacing.md : AppSpacing.xs,
                  ),
                  child: ShimmerLoadingContainer(
                    child: CustomShimmerContainer(
                      height: 12,
                      width: isParagraphEnd ? width * 0.5 : double.maxFinite,
                      borderRadius: AppRadius.field,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, state) {
        if (state is AppSettingsFetchSuccess) {
          // Check if the content is empty or contains only whitespace
          if (state.appSettingsResult.trim().isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: _topPadding(context)),
              child: CenteredNoDataContainer(
                titleKey: noDataFoundKey,
                occupiedHeight: _topPadding(context),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              top: _topPadding(context),
              left: AppSpacing.screenH,
              right: AppSpacing.screenH,
              bottom: AppSpacing.xl,
            ),
            child: Column(
              children: [
                _buildDocumentHeader(context),
                _buildContentCard(context, state.appSettingsResult),
              ],
            ),
          );
        }
        if (state is AppSettingsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessageCode: state.errorMessage,
              onTapRetry: () {
                if (useSchoolSettings) {
                  context
                      .read<AppSettingsCubit>()
                      .fetchSchoolSettings(type: appSettingsType);
                } else {
                  context
                      .read<AppSettingsCubit>()
                      .fetchAppSettings(type: appSettingsType);
                }
              },
            ),
          );
        }
        return _buildLoadingSkeleton(context);
      },
    );
  }
}
