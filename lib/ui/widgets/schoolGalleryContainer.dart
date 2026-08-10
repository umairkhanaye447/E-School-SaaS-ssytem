import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/schoolConfigurationCubit.dart';
import 'package:eschool/cubits/schoolGalleryCubit.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/ui/styles/appTokens.dart';
import 'package:eschool/ui/widgets/dashboard/sectionHeader.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

String _countsLabel(dynamic gallery) {
  final parts = <String>[];
  if (gallery.getImages().isNotEmpty) {
    parts.add(
        "${gallery.getImages().length} ${Utils.getTranslatedLabel(gallery.getImages().length == 1 ? photoKey : photosKey)}");
  }
  if (gallery.getVideos().isNotEmpty) {
    parts.add(
        "${gallery.getVideos().length} ${Utils.getTranslatedLabel(gallery.getVideos().length == 1 ? videoKey : videosKey)}");
  }
  return parts.join(" | ");
}

class SchoolGalleryContainer extends StatelessWidget {
  final Student student;
  const SchoolGalleryContainer({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SchoolGalleryCubit, SchoolGalleryState>(
      builder: (context, state) {
        if (state is SchoolGalleryFetchSuccess) {
          final schoolGallery = state.gallery;
          if (schoolGallery.isEmpty) {
            return const SizedBox();
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH),
                child: SectionHeader(
                  title: Utils.getTranslatedLabel(galleryKey),
                  icon: Icons.photo_library_rounded,
                  iconColor: AppAccent.purple.icon,
                  onTapAction: () {
                    Get.toNamed(Routes.schoolGallery, arguments: student);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 196,
                child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: Utils.screenContentHorizontalPadding),
                    scrollDirection: Axis.horizontal,
                    itemCount: schoolGallery.length,
                    itemBuilder: (context, index) {
                      final gallery = schoolGallery[index];
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(
                            end: AppSpacing.sm),
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.galleryDetails, arguments: {
                              "gallery": gallery,
                              "sessionYear": context
                                  .read<SchoolConfigurationCubit>()
                                  .getSchoolConfiguration()
                                  .sessionYear
                            });
                          },
                          child: Container(
                            width: 150,
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.cardAll,
                              boxShadow: AppShadows.card,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.iconTile),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 118,
                                    child: gallery.isThumbnailSvg()
                                        ? SvgPicture.network(
                                            gallery.thumbnail ?? "")
                                        : CachedNetworkImage(
                                            imageUrl: gallery.thumbnail ?? "",
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  (gallery.title ?? ""),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _countsLabel(gallery),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}
