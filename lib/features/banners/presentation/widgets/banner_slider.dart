import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/cubit/resource_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/banner_entity.dart';
import '../cubit/banner_cubit.dart';

/// Self-contained home-page banner carousel — fetches `/banners`
/// independently of the aggregate `/home` response and renders nothing
/// (not even a skeleton gap) when the list comes back empty or errors,
/// per the API contract.
class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late final BannerCubit _cubit = sl<BannerCubit>()..load();
  int _currentIndex = 0;

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerCubit, ResourceState<List<BannerEntity>>>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is ResourceLoading<List<BannerEntity>>) {
          return _buildSkeleton();
        }
        if (state is ResourceLoaded<List<BannerEntity>> &&
            state.data.isNotEmpty) {
          return _buildSlider(state.data);
        }
        // Empty list or error → show nothing, per spec.
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSlider(List<BannerEntity> banners) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: banners.length,
          options: CarouselOptions(
            height: 180,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            autoPlay: banners.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            onPageChanged: (i, _) => setState(() => _currentIndex = i),
          ),
          itemBuilder: (context, index, _) => AppNetworkImage(
            url: banners[index].imageUrl,
            width: double.infinity,
            height: 180,
            radius: AppRadius.md,
            fallbackIcon: Icons.image_not_supported_outlined,
          ),
        ),
        if (banners.length > 1) ...[
          const SizedBox(height: 10),
          AnimatedSmoothIndicator(
            activeIndex: _currentIndex,
            count: banners.length,
            effect: const ExpandingDotsEffect(
              activeDotColor: AppColors.primary,
              dotColor: AppColors.border,
              dotHeight: 7,
              dotWidth: 7,
              expansionFactor: 3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }
}
