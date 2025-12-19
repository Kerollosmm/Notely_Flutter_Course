import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_course_2/blocs/search/search_bloc.dart';
import 'package:flutter_course_2/constants/app_colors.dart';
import 'package:flutter_course_2/constants/app_dimensions.dart';
import 'package:flutter_course_2/services/repository/note_repository.dart';
import 'package:flutter_course_2/widgets/custom_text_field.dart';
import 'package:flutter_course_2/widgets/note_card.dart';
import 'package:flutter_course_2/widgets/category_chip.dart';
import 'package:flutter_course_2/constants/padge_routs.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(NoteRepository()),
      child: const _SearchScreenView(),
    );
  }
}

class _SearchScreenView extends StatefulWidget {
  const _SearchScreenView({Key? key}) : super(key: key);

  @override
  State<_SearchScreenView> createState() => _SearchScreenViewState();
}

class _SearchScreenViewState extends State<_SearchScreenView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final List<String> _filters = ['Text', 'Tags', 'Images', 'Audio'];
  String _selectedFilter = 'Text';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<SearchBloc>().add(SearchQueryChanged(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: CustomTextField(
          controller: _searchController,
          hintText: 'Search...',
          prefixIcon: Icons.search,
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              context.read<SearchBloc>().add(const SearchQueryChanged(''));
            },
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: AppDimensions.paddingM),
          _buildFilterChips(),
          SizedBox(height: AppDimensions.paddingM),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SearchLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                        child: Text(
                          'Found ${state.results.length} notes with "${state.query}"',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(AppDimensions.paddingM),
                          itemCount: state.results.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: AppDimensions.paddingM),
                              child: NoteCard(
                                note: state.results[index],
                                searchQuery: state.query,
                                onTap: () {
                                  Navigator.pushNamed(context, createOrUpdateNoteRoute, arguments: state.results[index]);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
                if (state is SearchInitial) {
                  return _buildSuggestions();
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      child: Row(
        children: _filters.map((filter) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: CategoryChip(
              label: filter,
              isSelected: filter == _selectedFilter,
              onTap: () {
                setState(() => _selectedFilter = filter);
                context.read<SearchBloc>().add(SearchFilterChanged(filter));
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You might also look for',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey),
          ),
          SizedBox(height: AppDimensions.paddingM),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _suggestionChip('Ideas'),
              _suggestionChip('Work'),
              _suggestionChip('Design'),
              _suggestionChip('To-do'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _searchController.text = label;
        _onSearchChanged(label);
      },
      backgroundColor: AppColors.surface,
    );
  }
}
