import 'package:eschool/data/models/announcement.dart';
import 'package:eschool/ui/widgets/studyMaterialWithDownloadButtonContainer.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';

class AnnouncementDetailsContainer extends StatefulWidget {
  final Announcement announcement;
  const AnnouncementDetailsContainer({Key? key, required this.announcement})
      : super(key: key);

  @override
  State<AnnouncementDetailsContainer> createState() =>
      _AnnouncementDetailsContainerState();
}

class _AnnouncementDetailsContainerState
    extends State<AnnouncementDetailsContainer>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  bool get _shouldShowReadMore {
    return widget.announcement.description.length >
        maxAnnouncementDescriptionLength;
  }

  String get _displayText {
    if (!_shouldShowReadMore) {
      return widget.announcement.description;
    }
    return _isExpanded
        ? widget.announcement.description
        : '${widget.announcement.description.substring(0, maxAnnouncementDescriptionLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _shouldShowReadMore
          ? () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.screenH,
          right: AppSpacing.screenH,
          bottom: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        //Without this the card shrinks to its content, so a short notice
        //renders narrower than one carrying an attachment.
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardAll,
          boxShadow: AppShadows.card,
        ),
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.announcement.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(
                  height: widget.announcement.description.isEmpty ? 0 : 5,
                ),
                widget.announcement.description.isEmpty
                    ? const SizedBox()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Text(
                              _displayText,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(height: 1.3),
                            ),
                          ),
                          if (_shouldShowReadMore) ...[
                            const SizedBox(height: 5),
                            Text(
                              _isExpanded
                                  ? Utils.getTranslatedLabel(readLessKey)
                                  : Utils.getTranslatedLabel(readMoreKey),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ],
                      ),
                ...widget.announcement.files
                    .map(
                      (studyMaterial) => GestureDetector(
                        onTap: null, // Disable parent tap for file downloads
                        child: StudyMaterialWithDownloadButtonContainer(
                          boxConstraints: boxConstraints,
                          studyMaterial: studyMaterial,
                        ),
                      ),
                    )
                    .toList(),
                SizedBox(
                  height: widget.announcement.files.isNotEmpty ? 0 : 5,
                ),
                Text(
                  Utils.formatApiDate(widget.announcement.createdAt),
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.start,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
