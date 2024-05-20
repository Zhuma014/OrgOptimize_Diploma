// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urven/data/models/club/club_events.dart';
import 'package:urven/ui/theme/palette.dart';
import 'package:urven/utils/screen_size_configs.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    event.title ?? 'No Title',
                    style: const TextStyle(
                      fontSize: SSC.p16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Description
                  if (event.description != null &&
                      event.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        event.description!,
                        style: const TextStyle(fontSize: SSC.p14),
                      ),
                    ),
                  // Date and Time
                  if (event.date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(event.date!),
                        style: const TextStyle(
                          fontSize: SSC.p12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  // Location
                  if (event.location != null && event.location!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            event.location!,
                            style: const TextStyle(
                                fontSize: SSC.p12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  // Handle potential errors
                  if (event.exception != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Error: ${event.exception}',
                        style:
                            const TextStyle(fontSize: SSC.p12, color: Colors.red),
                      ),
                    ),
                  // Cancel Button
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Palette.MAIN),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it!'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: SizedBox(
  width: 200,
  child: Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0), // Adjust the value as needed
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            event.title ?? 'No Title',
            style: const TextStyle(
              fontSize: SSC.p16,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Description
          if (event.description != null && event.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                event.description!,
                style: const TextStyle(fontSize: SSC.p14),
              ),
            ),
          // Date and Time
          if (event.date != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                DateFormat('dd MMM yyyy').format(event.date!),
                style: const TextStyle(
                  fontSize: SSC.p12,
                  color: Colors.grey,
                ),
              ),
            ),
          // Location
          if (event.location != null && event.location!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    event.location!,
                    style: const TextStyle(
                        fontSize: SSC.p12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          // Handle potential errors
          if (event.exception != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Error: ${event.exception}',
                style: const TextStyle(fontSize: SSC.p12, color: Colors.red),
              ),
            ),
        ],
      ),
    ),
  ),
),

    );
  }
}
